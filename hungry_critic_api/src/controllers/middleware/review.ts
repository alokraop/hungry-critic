import { Request, Response, NextFunction } from 'express';
import Container from 'typedi';
import { TokenInfo } from '../../models/internal';
import { Review, ReviewComment } from '../../models/review';
import { ReviewService } from '../../services/reviews';

const service = () => Container.get(ReviewService);

export const MakeReview = async (req: Request, res: Response, next: NextFunction) => {
  const review: Review = req.body;
  const caller: TokenInfo = res.locals.info;
  res.locals.review = <Review>{
    ...review,
    restaurant: res.locals.rId,
    author: req.params.id ?? caller.id,
    timestamp: new Date().getTime(),
  };
  next();
};

export const MakeResponse = async (req: Request, res: Response, next: NextFunction) => {
  const response: ReviewComment = req.body;
  res.locals.response = <ReviewComment>{
    ...response,
    reviewer: req.params.id,
  };
  next();
};

export const FetchReview = async (req: Request, res: Response, next: NextFunction) => {
  res.locals.review = await service().fetch(res.locals.rId, req.params.id);
  next();
};

export const AllowAuthor = (_: Request, res: Response): boolean => {
  const review: Review = res.locals.review;
  const caller: TokenInfo = res.locals.info;
  return review.author === caller.id;
};
