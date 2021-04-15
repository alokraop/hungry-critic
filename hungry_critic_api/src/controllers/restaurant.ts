import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { Restaurant } from '../models/restaurant';
import { RestaurantService } from '../services/restaurant';
import { Validate } from './middleware/validation';

export const restaurantRouter: Router = Router();

const service = () => Container.get(RestaurantService);

restaurantRouter.get('/', async (req: Request, res: Response) => {
  console.log(req.query['rating']);
  const restaurants = await service().findAll(res.locals.info);
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
