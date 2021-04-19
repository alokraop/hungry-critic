import { Service } from 'typedi';
import { RestaurantDao } from '../data/restaurants';
import { UserRole } from '../models/account';
import { FilterCriteria, Restaurant, RestaurantDetails } from '../models/restaurant';

import { v4 as uuid } from 'uuid';
import { APIError } from '../controllers/middleware/error';
import { TokenInfo } from '../models/internal';
import { Review, ReviewResponse } from '../models/review';
import { ReviewService } from './reviews';

@Service()
export class RestaurantService {
  constructor(private dao: RestaurantDao, private rService: ReviewService) {}

  async fetch(id: string): Promise<RestaurantDetails> {
    const restaurant = await this.dao.fetch(id);
    if (!restaurant) throw new APIError("This restaurant doesn't exist");
    return restaurant;
  }

  async findAll(criteria: FilterCriteria, caller: TokenInfo): Promise<RestaurantDetails[]> {
    switch (caller.role) {
      case UserRole.CUSTOMER:
        const cursor = await this.dao.findSorted(criteria, { averageRating: 1 }, { _id: 0 });
        return cursor.toArray();
      case UserRole.OWNER:
        return this.dao.findAll({ owner: caller.id, ...criteria });
      case UserRole.ADMIN:
        return this.dao.findAll(criteria);
    }
  }

  async create(spec: Restaurant, caller: TokenInfo): Promise<Restaurant> {
    if (caller.role !== UserRole.OWNER) {
      throw new APIError("You don't have priviledges to create restaurants!");
    }

    const restaurant = <RestaurantDetails>{
      id: uuid(),
      owner: caller.id,
      ...spec,
      totalRatings: 0,
      totalReviews: 0,
      averageRating: 0,
    };
    await this.dao.save(restaurant);
    return restaurant;
  }

  async update(id: string, update: Restaurant, caller: TokenInfo): Promise<any> {
    const restaurant = await this.dao.find({ id });
    if (restaurant?.owner !== caller.id && caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to update this restaurant!", 403);
    }
    this.dao.update({ id }, update);
  }

  async delete(id: string, caller: TokenInfo): Promise<any> {
    const restaurant = await this.fetch(id);
    if (restaurant.owner !== caller.id && caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to delete this restaurant!", 403);
    }
    return Promise.all([this.dao.delete({ id }), this.rService.deleteAll(id)]);
  }

  async addReview(id: string, review: Review, caller: TokenInfo): Promise<any> {
    if (caller.role !== UserRole.CUSTOMER) {
      throw new APIError("You don't have priviledges to create a review!");
    }
    review.restaurant = id;
    review.author = caller.id;
    await this.rService.create(review);

    const restaurant = await this.fetch(review.restaurant);
    this.addRating(restaurant, review);
    this.updateHighlights(restaurant, review);

    return this.dao.update({ id: review.restaurant }, restaurant);
  }

  async updateReview(review: Review, caller: TokenInfo) {
    if (review.author !== caller.id && caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to update this review!");
    }
    const [oldReview, restaurant] = await Promise.all([
      this.rService.fetch(review.restaurant, review.author),
      this.fetch(review.restaurant),
    ]);

    await this.rService.update(review);

    this.removeRating(restaurant, oldReview);
    this.addRating(restaurant, review);
    await this.assignHighlights(restaurant);

    return this.dao.update({ id: review.restaurant }, restaurant);
  }

  async deleteReview(id: string, rId: string, caller: TokenInfo) {
    if (caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to delete this review!");
    }
    const [oldReview, restaurant] = await Promise.all([
      this.rService.fetch(rId, id),
      this.fetch(rId),
    ]);

    await this.rService.delete(rId, id);

    this.removeRating(restaurant, oldReview);
    await this.assignHighlights(restaurant);

    return this.dao.update({ id: rId }, restaurant);
  }

  async deleteReviews(of: string): Promise<any> {
    const reviews = await this.rService.deleteFor(of);
    const ids = Array.from(new Set(reviews.map((r) => r.restaurant)));
    const restaurants = await this.dao.findAll({ id: { $in: ids } });

    const futures = restaurants.map(async (r) => this.removeReviews(r, reviews));
    return Promise.all(futures);
  }

  private async removeReviews(restaurant: RestaurantDetails, reviews: Array<Review>) {
    const rs = reviews.filter((r) => r.restaurant === restaurant.id);
    rs.forEach((r) => this.removeRating(restaurant, r));
    await this.assignHighlights(restaurant);
    return this.dao.update({ id: restaurant.id }, restaurant);
  }

  async deleteAll(owner: string): Promise<any> {
    const restaurants = await this.dao.findAll({ owner });
    await this.dao.deleteAll({ owner });
    return Promise.all(restaurants.map((r) => this.rService.deleteAll(r.id)));
  }

  async addReply(id: string, author: string, reply: ReviewResponse, info: TokenInfo): Promise<any> {
    if (info.role === UserRole.CUSTOMER) {
      throw new APIError("You can't modify this review!");
    }

    const restaurant = await this.dao.find({ id });
    if (!restaurant) throw new APIError('This restaurant does not exist!');

    if (restaurant.owner !== info.id && info.role !== UserRole.ADMIN) {
      throw new APIError("You can't modify this review!");
    }

    const review = await this.rService.updateReply(restaurant.id, author, reply);
    const changes = this.updateReviews(restaurant, review);
    if (changes) await this.dao.update({ id: restaurant.id }, restaurant);
  }

  async removeReply(id: string, author: string, info: TokenInfo): Promise<any> {
    if (info.role !== UserRole.ADMIN) throw new APIError("You can't delete the reply");

    const restaurant = await this.dao.find({ id });
    if (!restaurant) throw new APIError('This restaurant does not exist!');

    const review = await this.rService.deleteReply(restaurant.id, author);
    const changes = this.updateReviews(restaurant, review);
    if (changes) await this.dao.update({ id: restaurant.id }, restaurant);
  }

  private addRating(restaurant: RestaurantDetails, review: Review) {
    const aggRating = restaurant.averageRating * restaurant.totalRatings + review.rating;
    restaurant.totalRatings += 1;
    if (review.review) restaurant.totalReviews += 1;
    restaurant.averageRating = aggRating / restaurant.totalRatings;
  }

  private removeRating(restaurant: RestaurantDetails, review: Review) {
    const aggRating = restaurant.averageRating * restaurant.totalRatings - review.rating;
    restaurant.totalRatings -= 1;
    if (review.review) restaurant.totalReviews -= 1;

    const total = restaurant.totalRatings;
    restaurant.averageRating = total === 0 ? 0 : aggRating / total;
  }

  private updateHighlights(restaurant: RestaurantDetails, review: Review) {
    const bestRating = restaurant.bestReview?.rating ?? 0;
    if (review.rating >= bestRating) restaurant.bestReview = review;

    const worstRating = restaurant.worstReview?.rating ?? 10;
    if (review.rating <= worstRating) restaurant.worstReview = review;
  }

  private async assignHighlights(restaurant: RestaurantDetails) {
    const [best, worst] = await Promise.all([
      this.rService.findBest(restaurant.id),
      this.rService.findWorst(restaurant.id),
    ]);
    restaurant.bestReview = best ?? undefined;
    restaurant.worstReview = worst ?? undefined;
  }

  private updateReviews(restaurant: RestaurantDetails, review: Review) {
    if (restaurant.bestReview?.author === review.author) {
      restaurant.bestReview = review;
      return true;
    }
    if (restaurant.worstReview?.author === review.author) {
      restaurant.worstReview = review;
      return true;
    }
    return false;
  }
}
