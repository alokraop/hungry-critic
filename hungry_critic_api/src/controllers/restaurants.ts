import { Router, Request, Response, NextFunction } from 'express';

import { Container } from 'typedi';
import { FilterCriteria, Restaurant } from '../models/restaurant';
import { RestaurantService } from '../services/restaurants';
import { Validate } from './middleware/validation';
import { reviewRouter } from './reviews';

export const restaurantRouter: Router = Router();

const service = () => Container.get(RestaurantService);

restaurantRouter.get('/', async (req: Request, res: Response) => {
  const criteria = new FilterCriteria(req.query);
  const restaurants = await service().findAll(criteria, res.locals.info);
  res.json(restaurants);
});

restaurantRouter.post('/', Validate(Restaurant), async (req: Request, res: Response) => {
  const restaurant = await service().create(req.body, res.locals.info);
  res.json(restaurant);
});

restaurantRouter.put('/:id', Validate(Restaurant), async (req: Request, res: Response) => {
  await service().update(req.params.id, req.body, res.locals.info);
  res.send();
});

restaurantRouter.delete('/:id', async (req: Request, res: Response) => {
  await service().delete(req.params.id, res.locals.info);
  res.send();
});

restaurantRouter.use(
  '/:rId/reviews',
  (req: Request, res: Response, next: NextFunction) => {
    res.locals.rId = req.params.rId;
    next();
  },
  reviewRouter,
);
