import { Request, Response, NextFunction } from 'express';
import Container from 'typedi';
import { TokenInfo } from '../../models/internal';
import { RestaurantDetails } from '../../models/restaurant';
import { RestaurantService } from '../../services/restaurants';

const service = () => Container.get(RestaurantService);

export const FetchRestaurant = async (req: Request, res: Response, next: NextFunction) => {
  const id = req.params.rId ?? res.locals.rId;
  res.locals.restaurant = await service().fetch(id);
  next();
};

export const AllowOwner = (_: Request, res: Response): boolean => {
  const restaurant: RestaurantDetails = res.locals.restaurant;
  const caller: TokenInfo = res.locals.info;
  return restaurant.owner === caller.id;
};
