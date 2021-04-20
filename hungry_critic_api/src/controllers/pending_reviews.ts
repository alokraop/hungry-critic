import { Router, Request, Response } from 'express';
import Container from 'typedi';
import { PageInfo } from '../models/internal';
import { RestaurantService } from '../services/restaurants';

export const reviewRouter: Router = Router();

const service = () => Container.get(RestaurantService);

reviewRouter.get('/', async (req: Request, res: Response) => {
  const reviews = await service().findReviews(new PageInfo(req.query), res.locals.info);
  res.json(reviews);
});
