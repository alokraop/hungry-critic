import { Allow, IsDefined, IsNumber } from 'class-validator';
import { Review } from './review';

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

  bestReview?: Review;

  worstReview?: Review;
}

export class FilterCriteria {
  public minRating: number;
  public maxRating: number;

  constructor(query: any) {
    const rating = query['rating'];
    if (rating) {
      if (rating instanceof String) {
        this.initRating(rating);
      } else {
        rating.forEach((r: string) => this.initRating(r));
      }
    }
  }

  makeQuery() {
    const query: any = {};
    if (this.minRating) query.minRating = this.minRating;
    if (this.maxRating) query.maxRating = this.maxRating;
    return query;
  }

  private initRating(filter: String) {
    const parts = filter.split(':');
    switch (parts[0]) {
      case 'lte':
        this.maxRating = parseFloat(parts[1]);
        break;
      case 'gte':
        this.minRating = parseFloat(parts[1]);
        break;
    }
  }
}
