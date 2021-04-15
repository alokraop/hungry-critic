import { Allow, IsDefined, IsPositive } from 'class-validator';

export class Review {
  @Allow()
  author: string;

  @Allow()
  restaurant: string;

  @IsDefined()
  @IsPositive()
  rating: number;

  @Allow()
  review: string;

  @IsDefined()
  @IsPositive()
  timestamp: number;
}
