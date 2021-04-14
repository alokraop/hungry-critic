import 'reflect-metadata';
import { Authenticate } from './auth';
import Container from 'typedi';
import { TokenService } from '../../services/token';
import { LoggingService } from '../../services/logging';
import { getMockReq, getMockRes } from '@jest-mock/express';
jest.mock('../../services/token');
jest.mock('../../services/logging');

describe('All auth variations', () => {
  beforeAll(() => {
    const verify = TokenService.prototype.verify as jest.Mock;
    verify.mockImplementation((token: string) => {
      return token === 'good' ? 'test-id' : undefined;
    });
    Container.set(TokenService, new TokenService(new LoggingService()));
  });

  test('Good token', () => {
    const req = getMockReq({ headers: { token: 'good' } });
    const { res, next } = getMockRes();
    Authenticate(req, res, next);

    expect(res.locals.accountId).toBe('test-id');
    expect(next).toBeCalledTimes(1);
  });

  test('Bad token', () => {
    const req = getMockReq({ headers: { token: 'bad' } });
    const { res, next } = getMockRes();
    try {
      Authenticate(req, res, next);
    } catch (e) {
      expect(e.message).toBe('Invalid or missing token');
    }
    expect(next).toBeCalledTimes(0);
  });
});
