import { Router, Request, Response, NextFunction } from 'express';

import { Container } from 'typedi';
import { UserRole } from '../models/account';
import { PageInfo } from '../models/internal';
import { FilterCriteria, Restaurant } from '../models/restaurant';
import { RestaurantService } from '../services/restaurants';
import { Roles, Allow } from './middleware/authorize';
import { AllowOwner, FetchRestaurant } from './middleware/restaurant';
import { Validate } from './middleware/validation';
import { reviewRouter } from './reviews';

export const restaurantRouter: Router = Router();

const service = () => Container.get(RestaurantService);

restaurantRouter.get('/', async (req: Request, res: Response) => {
  const restaurants = await service().findAll(
    new FilterCriteria(req.query),
    new PageInfo(req.query),
    res.locals.info,
  );
  res.json(restaurants);
});

restaurantRouter.get('/:rId', async (req: Request, res: Response) => {
  const restaurant = await service().fetch(req.params.rId);
  res.json(restaurant);
});

restaurantRouter.post(
  '/',
  Validate(Restaurant),
  Allow(Roles(UserRole.OWNER)),
  async (req: Request, res: Response) => {
    const restaurant = await service().create(req.body, res.locals.info);
    res.status(201).json(restaurant);
  },
);

restaurantRouter.put(
  '/:rId',
  Validate(Restaurant),
  Allow(Roles(UserRole.ADMIN, UserRole.OWNER)),
  FetchRestaurant,
  Allow(Roles(UserRole.ADMIN), AllowOwner),
  async (req: Request, res: Response) => {
    await service().update(req.params.rId, req.body);
    res.send();
  },
);

restaurantRouter.delete(
  '/:rId',
  Allow(Roles(UserRole.ADMIN, UserRole.OWNER)),
  FetchRestaurant,
  Allow(Roles(UserRole.ADMIN), AllowOwner),
  async (req: Request, res: Response) => {
    await service().delete(req.params.rId);
    res.send();
  },
);

restaurantRouter.use(
  '/:rId/reviews',
  (req: Request, res: Response, next: NextFunction) => {
    res.locals.rId = req.params.rId;
    next();
  },
  reviewRouter,
);
