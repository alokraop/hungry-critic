import { MongoError } from 'mongodb';
import { Service } from 'typedi';
import { APIError } from '../controllers/middleware/error';
import { ReviewsDao } from '../data/reviews';
import { PageInfo } from '../models/internal';
import { Review, ReviewComment } from '../models/review';

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

  async findPending(ids: Array<string>, page: PageInfo): Promise<Review[]> {
    return this.dao.findAll({ restaurant: { $in: ids }, reply: { $exists: false } }, {}, page);
  }

  async findAll(id: string, page: PageInfo): Promise<Review[]> {
    return this.dao.findAll({ restaurant: id }, {}, page);
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

  async deleteForAuthor(of: string): Promise<Array<Review>> {
    const reviews = await this.dao.findAll({ author: of });
    await this.dao.deleteAll({ author: of });
    return reviews;
  }

  async addComment(restaurant: string, comment: ReviewComment): Promise<Review> {
    const review = await this.fetch(restaurant, comment.reviewer);
    if (review.reply) throw new APIError('This review already has a reply!');

    review.reply = comment.response;
    await this.dao.update({ restaurant, author: comment.reviewer }, review);
    return review;
  }

  async updateComment(restaurant: string, comment: ReviewComment): Promise<Review> {
    const review = await this.fetch(restaurant, comment.reviewer);
    if (!review.reply) throw new APIError('This review does not have a reply to update!');

    review.reply = comment.response;
    await this.dao.update({ restaurant, author: comment.reviewer }, review);
    return review;
  }

  async deleteComment(restaurant: string, author: string): Promise<Review> {
    const review = await this.fetch(restaurant, author);

    delete review.reply;
    await this.dao.rawUpdate({ restaurant, author }, { $unset: { reply: '' } });
    return review;
  }
}
