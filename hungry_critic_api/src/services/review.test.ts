import { MongoError } from 'mongodb';
import { APIError } from '../controllers/middleware/error';
import { ReviewsDao } from '../data/reviews';
import { Review } from '../models/review';
import { ReviewService } from './reviews';
jest.mock('../data/reviews');

describe('All review services', () => {
  let dao: ReviewsDao;
  let service: ReviewService;

  beforeAll(() => {
    const find = ReviewsDao.prototype.find as jest.Mock;
    find.mockImplementation((q) => {
      return q.author === 'bad-id'
        ? undefined
        : <Review>{ author: q.author, restaurant: q.restaurant, rating: 4, review: 'some-review' };
    });
    dao = new ReviewsDao();
    service = new ReviewService(dao);
  });

  test('Find Review', async () => {
    const review = await service.fetch('some-restaurant', 'good-id');

    expect(review.author).toBe('good-id');
    expect(review.restaurant).toBe('some-restaurant');
  });

  test('Add Review', async () => {
    const review = <Review>{
      author: 'some-author',
      restaurant: 'restaurant',
      rating: 3,
      dateOfVisit: 11903490,
    };
    await service.create(review);

    expect(dao.save).toBeCalled();
  });

  test('Add Duplicate', async () => {
    const review = <Review>{
      author: 'some-author',
      restaurant: 'restaurant',
      rating: 3,
      dateOfVisit: 11903490,
    };
    const save = ReviewsDao.prototype.save as jest.Mock;
    save.mockImplementation((_) => {
      throw new MongoError({ code: 11000 });
    });

    expect(() => service.create(review)).rejects.toThrow(APIError);
  });

  test('Add comment', async () => {
    await service.addComment('some-restaurant', {
      response: 'some-comment',
      reviewer: 'some-author',
    });
    expect(dao.update).toBeCalledWith(
      { restaurant: 'some-restaurant', author: 'some-author' },
      expect.objectContaining({ reply: 'some-comment' }),
    );
  });
});
