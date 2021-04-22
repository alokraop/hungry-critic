import { getMockReq, getMockRes } from '@jest-mock/express';
import { UserRole } from '../../models/account';
import { MakeReview, MakeResponse } from './review';

describe('Making review entities', () => {
  test('Review', () => {
    const reqReview = { rating: 3, review: 'Good stuff', dateOfVisit: 923839834 };
    const req = getMockReq({ body: reqReview });

    const info = { id: 'some-id', role: UserRole.USER };
    const { res, next } = getMockRes({ locals: { info, rId: 'some-restaurant' } });

    MakeReview(req, res, next);

    expect(next).toBeCalled();

    const review = res.locals.review;

    expect(review.author).toBe(info.id);
    expect(review.restaurant).toBe('some-restaurant');
    expect(review.rating).toBe(reqReview.rating);
  });

  test('Response', () => {
    const reqRes = { response: 'Thanks!' };
    const req = getMockReq({ body: reqRes, params: { id: 'some-id'} });

    const { res, next } = getMockRes();

    MakeResponse(req, res, next);

    expect(next).toBeCalled();

    const response = res.locals.response;

    expect(response.response).toBe(reqRes.response);
    expect(response.reviewer).toBe('some-id');
  });
});
