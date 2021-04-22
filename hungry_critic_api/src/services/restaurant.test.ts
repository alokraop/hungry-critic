import { RestaurantDao } from '../data/restaurants';
import { ReviewsDao } from '../data/reviews';
import { RestaurantDetails } from '../models/restaurant';
import { Review } from '../models/review';
import { RestaurantService } from './restaurants';
import { ReviewService } from './reviews';

jest.mock('./reviews');
jest.mock('../data/reviews');
jest.mock('../data/restaurants');

const dReview = <Review>{
  author: 'some-author',
  restaurant: 'some-id',
  rating: 4,
  review: 'some-review',
};

const dRestaurant = <RestaurantDetails>{
  id: 'some-id',
  name: 'some-name',
  address: 'some-address',
  cuisines: ['some-cuisine'],
  averageRating: 4,
  totalRatings: 2,
  totalReviews: 2,
};

describe('All restaurant services', () => {
  let dao: RestaurantDao;
  let rService: ReviewService;
  let service: RestaurantService;

  beforeAll(() => {
    dao = new RestaurantDao();
    rService = new ReviewService(new ReviewsDao());
    service = new RestaurantService(dao, rService);
  });

  test('Add Review', async () => {
    await service.addReview(dReview, dRestaurant);

    expect(dao.update).toBeCalledWith(
      { id: dRestaurant.id },
      expect.objectContaining({
        averageRating: 4,
        totalRatings: 3,
        bestReview: dReview,
        worstReview: dReview,
      }),
    );
  });

  test('Update Review', async () => {
    const restaurant = <RestaurantDetails>{
      ...dRestaurant,
      averageRating: 4.3,
      totalRatings: 10,
      totalReviews: 10,
      bestReview: {
        author: 'some-author',
        rating: 5,
      },
      worstReview: {
        author: 'second-author',
        rating: 3,
      },
    };
    const review = { ...dReview, rating: 2 };

    const fetch = ReviewService.prototype.fetch as jest.Mock;
    fetch.mockImplementation((_, __) => {
      return {
        author: dReview.author,
        restaurant: dRestaurant.id,
        rating: 5,
        review: 'some-review',
      };
    });

    const best = ReviewService.prototype.findBest as jest.Mock;
    best.mockImplementation((_) => {
      return {
        author: 'third-author',
        rating: 4.5,
      };
    });

    const worst = ReviewService.prototype.findWorst as jest.Mock;
    worst.mockImplementation((_) => {
      return {
        author: 'second-author',
        rating: 3,
      };
    });

    const update = dao.update as jest.Mock;
    update.mockClear();

    await service.updateReview(review, restaurant);

    expect(dao.update).toBeCalledWith(
      { id: dRestaurant.id },
      expect.objectContaining({
        averageRating: 4,
      }),
    );
  });
});
