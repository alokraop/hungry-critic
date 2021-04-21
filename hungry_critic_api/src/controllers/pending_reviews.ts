import { Router, Request, Response } from 'express';
import Container from 'typedi';
import { UserRole } from '../models/account';
import { PageInfo } from '../models/internal';
import { RestaurantService } from '../services/restaurants';
import { Roles, Allow } from './middleware/authorize';

export const reviewRouter: Router = Router();

const service = () => Container.get(RestaurantService);

reviewRouter.get(
  '/',
  Allow(Roles(UserRole.OWNER)),
  async (req: Request, res: Response) => {
    const reviews = await service().findReviews(new PageInfo(req.query), res.locals.info);
    res.json(reviews);
  },
);
