import { Cursor } from 'mongodb';
import { Service } from 'typedi';
import { Review } from '../models/review';
import { BaseDao } from './base';

@Service()
export class ReviewsDao extends BaseDao<Review> {
  constructor() {
    super('reviews', Review);
  }

  async findSorted(query: any = {}, on: any = {}): Promise<Cursor<Review>> {
    const client = await this.init();
    return client.find(query).sort(on);
  }
}
