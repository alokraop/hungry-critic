import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { UserRole } from '../models/account';
import { PageInfo } from '../models/internal';
import { Review, ReviewComment } from '../models/review';
import { RestaurantService } from '../services/restaurants';
import { ReviewService } from '../services/reviews';
import { Allow, Roles } from './middleware/authorize';
import { AllowOwner, FetchRestaurant } from './middleware/restaurant';
import { AllowAuthor, MakeResponse, MakeReview } from './middleware/review';
import { Validate } from './middleware/validation';

export const reviewRouter: Router = Router();

const service = () => Container.get(ReviewService);

const rService = () => Container.get(RestaurantService);

reviewRouter.get('/', async (req: Request, res: Response) => {
  const reviews = await service().findAll(res.locals.rId, new PageInfo(req.query));
  res.json(reviews);
});

reviewRouter.post(
  '/',
  Validate(Review),
  Allow(Roles(UserRole.USER)),
  MakeReview,
  FetchRestaurant,
  async (_: Request, res: Response) => {
    await rService().addReview(res.locals.review, res.locals.restaurant);
    res.status(201).send();
  },
);

reviewRouter.put(
  '/:id',
  Validate(Review),
  MakeReview,
  Allow(Roles(UserRole.ADMIN), AllowAuthor),
  FetchRestaurant,
  async (_: Request, res: Response) => {
    await rService().updateReview(res.locals.review, res.locals.restaurant);
    res.send();
  },
);

reviewRouter.delete(
  '/:id',
  Allow(Roles(UserRole.ADMIN)),
  FetchRestaurant,
  async (req: Request, res: Response) => {
    await rService().deleteReview(req.params.id, res.locals.restaurant);
    res.send();
  },
);

reviewRouter.post(
  '/:id/replies',
  Validate(ReviewComment),
  Allow(Roles(UserRole.OWNER)),
  FetchRestaurant,
  Allow(AllowOwner),
  MakeResponse,
  async (_: Request, res: Response) => {
    await rService().addComment(res.locals.restaurant, res.locals.response);
    res.status(201).send();
  },
);

reviewRouter.put(
  '/:id/replies',
  Validate(ReviewComment),
  Allow(Roles(UserRole.OWNER, UserRole.ADMIN)),
  FetchRestaurant,
  Allow(Roles(UserRole.ADMIN), AllowOwner),
  MakeResponse,
  async (req: Request, res: Response) => {
    await rService().updateComment(res.locals.restaurant, res.locals.response);
    res.send();
  },
);

reviewRouter.delete(
  '/:id/replies',
  Validate(ReviewComment),
  Allow(Roles(UserRole.ADMIN)),
  FetchRestaurant,
  async (req: Request, res: Response) => {
    const author = req.params.id;
    await rService().removeComment(res.locals.restaurant, author);
    res.send();
  },
);
