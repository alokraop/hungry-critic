import { Service } from 'typedi';
import { RestaurantDao } from '../data/restaurants';
import { UserRole } from '../models/account';
import { FilterCriteria, Restaurant, RestaurantDetails } from '../models/restaurant';

import { v4 as uuid } from 'uuid';
import { APIError } from '../controllers/middleware/error';
import { PageInfo, TokenInfo } from '../models/internal';
import { Review, ReviewComment } from '../models/review';
import { ReviewService } from './reviews';

@Service()
export class RestaurantService {
  constructor(private dao: RestaurantDao, private rService: ReviewService) {}

  async fetch(id: string): Promise<RestaurantDetails> {
    const restaurant = await this.dao.fetch(id);
    if (!restaurant) throw new APIError("This restaurant doesn't exist");
    return restaurant;
  }

  async findAll(
    criteria: FilterCriteria,
    page: PageInfo,
    caller: TokenInfo,
  ): Promise<RestaurantDetails[]> {
    let cursor;
    const query = { averageRating: { $lte: criteria.maxRating, $gte: criteria.minRating } };
    switch (caller.role) {
      case UserRole.CUSTOMER:
        cursor = await this.dao.findSorted(query, { averageRating: -1 }, { _id: 0 }, page);
      case UserRole.OWNER:
        cursor = await this.dao.findSorted(
          { owner: caller.id, ...query },
          { averageRating: -1 },
          { _id: 0 },
          page,
        );
      case UserRole.ADMIN:
        cursor = await this.dao.findSorted(query, { averageRating: -1 }, { _id: 0 }, page);
    }
    return cursor.toArray();
  }

  async create(spec: Restaurant, caller: TokenInfo): Promise<Restaurant> {
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

  async update(id: string, update: Restaurant): Promise<any> {
    this.dao.update({ id }, update);
  }

  async delete(id: string): Promise<any> {
    return Promise.all([this.dao.delete({ id }), this.rService.deleteAll(id)]);
  }

  async findReviews(page: PageInfo, caller: TokenInfo): Promise<any> {
    const restaurants = await this.dao.findAll({ owner: caller.id });
    return this.rService.findPending(
      restaurants.map((r) => r.id),
      page,
    );
  }

  async addReview(review: Review, restaurant: RestaurantDetails): Promise<any> {
    await this.rService.create(review);

    this.addToRating(restaurant, review);
    return this.updateHighlights(restaurant, review);
  }

  async updateReview(review: Review, restaurant: RestaurantDetails) {
    const oldReview = await this.rService.fetch(review.restaurant, review.author);

    await this.rService.update(review);

    this.removeFromRating(restaurant, oldReview);
    this.addToRating(restaurant, review);
    return this.assignHighlights(restaurant);
  }

  async deleteReview(id: string, restaurant: RestaurantDetails) {
    const oldReview = await this.rService.fetch(restaurant.id, id);

    await this.rService.delete(restaurant.id, id);

    this.removeFromRating(restaurant, oldReview);
    return this.assignHighlights(restaurant);
  }

  async addComment(restaurant: RestaurantDetails, comment: ReviewComment): Promise<any> {
    const review = await this.rService.addComment(restaurant.id, comment);
    return this.updateHighlights(restaurant, review);
  }

  async updateComment(restaurant: RestaurantDetails, comment: ReviewComment): Promise<any> {
    const review = await this.rService.updateComment(restaurant.id, comment);
    return this.updateHighlights(restaurant, review);
  }

  async removeComment(restaurant: RestaurantDetails, author: string): Promise<any> {
    const review = await this.rService.deleteComment(restaurant.id, author);
    return this.updateHighlights(restaurant, review);
  }

  async deleteForAuthor(author: string): Promise<any> {
    const reviews = await this.rService.deleteForAuthor(author);

    const rMap = new Map<string, Array<Review>>();
    reviews.forEach((r) => {
      if (!rMap.has(r.restaurant)) rMap.set(r.restaurant, []);
      rMap.get(r.restaurant)?.push(r);
    });

    const restaurants = await this.dao.findAll({ id: { $in: Array.from(rMap.keys()) } });

    const futures = restaurants.map((r) => {
      rMap.get(r.id)?.map((re) => this.removeFromRating(r, re));
      return this.assignHighlights(r);
    });
    return Promise.all(futures);
  }

  async deleteForOwner(owner: string): Promise<any> {
    const restaurants = await this.dao.findAll({ owner });
    await this.dao.deleteAll({ owner });
    return Promise.all(restaurants.map((r) => this.rService.deleteAll(r.id)));
  }

  private addToRating(restaurant: RestaurantDetails, review: Review) {
    const aggRating = restaurant.averageRating * restaurant.totalRatings + review.rating;
    restaurant.totalRatings += 1;
    if (review.review) restaurant.totalReviews += 1;
    restaurant.averageRating = aggRating / restaurant.totalRatings;
  }

  private removeFromRating(restaurant: RestaurantDetails, review: Review) {
    const aggRating = restaurant.averageRating * restaurant.totalRatings - review.rating;
    restaurant.totalRatings -= 1;
    if (review.review) restaurant.totalReviews -= 1;

    const total = restaurant.totalRatings;
    restaurant.averageRating = total === 0 ? 0 : aggRating / total;
  }

  private async assignHighlights(restaurant: RestaurantDetails): Promise<any> {
    const [best, worst] = await Promise.all([
      this.rService.findBest(restaurant.id),
      this.rService.findWorst(restaurant.id),
    ]);
    restaurant.bestReview = best ?? undefined;
    restaurant.worstReview = worst ?? undefined;

    return this.update(restaurant.id, restaurant);
  }

  private updateHighlights(restaurant: RestaurantDetails, review: Review): Promise<any> {
    const bestRating = restaurant.bestReview?.rating ?? 0;
    if (review.rating >= bestRating) restaurant.bestReview = review;

    const worstRating = restaurant.worstReview?.rating ?? 10;
    if (review.rating <= worstRating) restaurant.worstReview = review;

    return this.update(restaurant.id, restaurant);
  }
}
