import { Allow, IsDefined, IsNumber } from 'class-validator';

export class Restaurant {

  @IsDefined()
  name: string;

  @Allow()
  address: string;

  @Allow({ each: true })
  cuisines: string[];
}

export class RestaurantDetails extends Restaurant {
  @Allow()
  id: string;

  @Allow()
  owner: string;

  @IsNumber({ maxDecimalPlaces: 0 })
  totalRatings: number;

  @IsNumber({ maxDecimalPlaces: 0 })
  totalReviews: number;

  @IsNumber()
  averageRating: number;

}
