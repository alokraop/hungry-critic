import { getMockReq, getMockRes } from '@jest-mock/express';
import { APIError, HandleErrors } from './error';
import { LoggingService } from '../../services/logging';
import Container from 'typedi';
import { ValidationError } from 'class-validator';
jest.mock('../../services/logging');

describe('Handle all types of API errors', () => {
  beforeAll(() => {
    Container.set(LoggingService, new LoggingService());
  });
  test('Standard error', () => {
    const { res, next } = getMockRes();
    const error = expect.objectContaining({ message: 'Standard stuff' });
    HandleErrors(new APIError('Standard stuff'), getMockReq(), res, next);
    expect(res.status).toBeCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(error);
  });

  test('Custom status code', () => {
    const { res, next } = getMockRes();
    const error = expect.objectContaining({ message: 'Custom code' });
    HandleErrors(new APIError('Custom code', 403), getMockReq(), res, next);
    expect(res.status).toBeCalledWith(403);
    expect(res.json).toHaveBeenCalledWith(error);
  });

  test('Extra data', () => {
    const { res, next } = getMockRes();
    const error = expect.objectContaining({ message: 'Extra data', key: 'value' });
    HandleErrors(new APIError('Extra data', 403, { key: 'value' }), getMockReq(), res, next);
    expect(res.status).toBeCalledWith(403);
    expect(res.json).toHaveBeenCalledWith(error);
  });
});

describe('Handle other errors', () => {
  beforeAll(() => {
    Container.set(LoggingService, new LoggingService());
  });

  test('Validation error', () => {
    const { res, next } = getMockRes();
    const error = new ValidationError();
    error.property = 'email';
    const errors = [error];
    HandleErrors(errors, getMockReq(), res, next);
    expect(res.status).toBeCalledWith(422);
    expect(res.json).toHaveBeenCalledWith({ errors });
  });

  test('General error', () => {
    const { res, next } = getMockRes();
    const error = expect.objectContaining({ message: 'Unexpected error!' });
    HandleErrors(new Error('General error'), getMockReq(), res, next);
    expect(res.status).toBeCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(error);
  });
});
