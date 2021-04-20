import { Allow, IsDefined, IsPositive } from 'class-validator';

export class Review {
  @Allow()
  author: string;

  @Allow()
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

  @IsDefined()
  @IsPositive()
  timestamp: number;
}

export class ReviewResponse {
  @Allow()
  response: string;
}
