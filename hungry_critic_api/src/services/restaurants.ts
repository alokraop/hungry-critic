import { Service } from 'typedi';
import { RestaurantDao } from '../data/restaurants';
import { UserRole } from '../models/account';
import { FilterCriteria, Restaurant, RestaurantDetails } from '../models/restaurant';

import { v4 as uuid } from 'uuid';
import { APIError } from '../controllers/middleware/error';
import { TokenInfo } from '../models/internal';
import { Review } from '../models/review';
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
    if (id !== caller.id && caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to delete this review!");
    }
    const [oldReview, restaurant] = await Promise.all([
      this.rService.fetch(rId, id),
      this.fetch(rId),
    ]);

    await this.rService.delete(rId, caller.id);

    this.removeRating(restaurant, oldReview);
    await this.assignHighlights(restaurant);

    return this.dao.update({ id: rId }, restaurant);
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
}
