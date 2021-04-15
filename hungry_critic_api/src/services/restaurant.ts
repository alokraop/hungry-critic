import { Service } from 'typedi';
import { RestaurantDao } from '../data/restaurant';
import { UserRole } from '../models/account';
import { Restaurant, RestaurantDetails } from '../models/restaurant';

import { v4 as uuid } from 'uuid';
import { APIError } from '../controllers/middleware/error';
import { TokenInfo } from '../models/internal';

@Service()
export class RestaurantService {
  constructor(private dao: RestaurantDao) {}

  fetch(id: string): Promise<RestaurantDetails | null> {
    return this.dao.fetch(id);
  }

  async findAll(caller: TokenInfo): Promise<RestaurantDetails[]> {
    switch (caller.role) {
      case UserRole.CUSTOMER:
        const cursor = await this.dao.findSorted({}, { _id: 0, averageRating: 1 });
        return cursor.toArray();
      case UserRole.OWNER:
        return this.dao.findAll({ owner: caller.id });
      case UserRole.ADMIN:
        return this.dao.findAll({});
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
    throw new Error('Method not implemented.');
  }
}
