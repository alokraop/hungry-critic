import { Allow, IsDefined, IsPositive } from 'class-validator';

export class Review {
  @Allow()
  author: string;

  @IsDefined()
  authorName: string;

  @Allow()
  restaurant: string;

  @IsDefined()
  @IsPositive()
  rating: number;

  @IsDefined()
  review: string;

  @IsDefined()
  @IsPositive()
  dateOfVisit: number;

  reply?: string;

  timestamp: number;
}

export class ReviewComment {
  @Allow()
  response: string;

  reviewer: string;
}
