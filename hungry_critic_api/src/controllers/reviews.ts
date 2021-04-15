import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { Review } from '../models/review';
import { RestaurantService } from '../services/restaurants';
import { ReviewService } from '../services/reviews';
import { Validate } from './middleware/validation';

export const reviewRouter: Router = Router();

const service = () => Container.get(ReviewService);

const rService = () => Container.get(RestaurantService);

reviewRouter.get('/', async (_: Request, res: Response) => {
  const reviews = await service().findAll(res.locals.rId);
  res.json(reviews);
});

reviewRouter.post('/', Validate(Review), async (req: Request, res: Response) => {
  await rService().addReview(res.locals.rId, req.body, res.locals.info);
  res.status(201).send();
});

reviewRouter.put('/:id', Validate(Review), async (req: Request, res: Response) => {
  const review = <Review>{ author: req.params.id, restaurant: res.locals.rId, ...req.body };
  await rService().updateReview(review, res.locals.info);
  res.send();
});

reviewRouter.delete('/:id', async (req: Request, res: Response) => {
  await rService().deleteReview(req.params.id, res.locals.rId, res.locals.info);
  res.send();
});