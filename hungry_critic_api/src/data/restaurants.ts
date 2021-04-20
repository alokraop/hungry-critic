import { Cursor } from 'mongodb';
import { Service } from 'typedi';
import { PageInfo } from '../models/internal';
import { RestaurantDetails } from '../models/restaurant';
import { BaseDao } from './base';

@Service()
export class RestaurantDao extends BaseDao<RestaurantDetails> {
  constructor() {
    super('restaurants', RestaurantDetails);
  }

  async findSorted(
    query: any = {},
    on: any = {},
    projection: any = {},
    page: PageInfo,
  ): Promise<Cursor<RestaurantDetails>> {
    const client = await this.init();
    return client.find(query, { projection }).sort(on).skip(page.offset).limit(page.limit);
  }
}
