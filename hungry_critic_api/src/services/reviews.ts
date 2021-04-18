import { MongoError } from 'mongodb';
import { Service } from 'typedi';
import { APIError } from '../controllers/middleware/error';
import { ReviewsDao } from '../data/reviews';
import { Review, ReviewResponse } from '../models/review';

@Service()
export class ReviewService {
  constructor(private dao: ReviewsDao) {}

  async fetch(restaurant: string, author: string): Promise<Review> {
    const review = await this.dao.find({ author, restaurant });
    if (!review) throw new APIError('This review does not exist!');
    return review;
  }

  async findBest(id: string): Promise<Review | undefined> {
    const cursor = await this.dao.findSorted({ restaurant: id }, { rating: -1 });
    const results = await cursor.limit(1).toArray();
    return results.length === 0 ? undefined : results[0];
  }

  async findWorst(id: string): Promise<Review | undefined> {
    const cursor = await this.dao.findSorted({ restaurant: id }, { rating: 1 });
    const results = await cursor.limit(1).toArray();
    return results.length === 0 ? undefined : results[0];
  }

  async findAll(id: string): Promise<Review[]> {
    return this.dao.findAll({ restaurant: id });
  }

  async create(review: Review): Promise<any> {
    try {
      await this.dao.save(review);
    } catch (e) {
      if (e instanceof MongoError && e.code === 11000) {
        throw new APIError('Review already exists!');
      }
    }
  }

  update(review: Review): Promise<any> {
    return this.dao.update({ restaurant: review.restaurant, author: review.author }, review);
  }

  delete(rId: string, id: string): Promise<any> {
    return this.dao.delete({ restaurant: rId, author: id });
  }

  deleteAll(rId: string): Promise<any> {
    return this.dao.deleteAll({ restaurant: rId });
  }

  async updateReply(restaurant: string, author: string, reply: ReviewResponse): Promise<Review> {
    const review = await this.dao.find({ restaurant, author });
    if (!review) throw new APIError("This review doesn't exist");

    review.reply = reply.response;
    await this.dao.update({ restaurant, author }, review);
    return review;
  }

  async deleteReply(restaurant: string, author: string): Promise<Review> {
    const review = await this.dao.find({ restaurant, author });
    if (!review) throw new APIError("This review doesn't exist");

    delete review.reply;
    await this.dao.rawUpdate({ restaurant, author }, { $unset: { reply: '' } });
    return review;
  }
}
