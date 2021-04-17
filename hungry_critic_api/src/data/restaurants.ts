import { Cursor } from 'mongodb';
import { Service } from 'typedi';
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
  ): Promise<Cursor<RestaurantDetails>> {
    const client = await this.init();
    return client.find(query, { projection }).sort(on);
  }
}
