import { getMockReq, getMockRes } from '@jest-mock/express';
import { UserRole } from '../../models/account';
import { Allow, Roles } from './authorize';
import { APIError } from './error';

const response = (role: UserRole = UserRole.USER) => {
  return {
    locals: {
      info: {
        id: 'sdoifm32doimcvoi',
        role,
      },
    },
  };
};

describe('Checking all authorize variations', () => {
  test('Single Role', () => {
    const req = getMockReq();

    const { res, next } = getMockRes(response());

    const middleware = Allow(Roles(UserRole.USER));
    middleware(req, res, next);

    expect(next).toBeCalled();
  });

  test('Multiple Roles', () => {
    const req = getMockReq();
    const { res, next } = getMockRes(response(UserRole.OWNER));

    const middleware = Allow(Roles(UserRole.OWNER, UserRole.ADMIN));
    middleware(req, res, next);

    expect(next).toBeCalled();
  });

  test('Role - Fail', () => {
    const req = getMockReq();
    const { res, next } = getMockRes(response());

    const middleware = Allow(Roles(UserRole.OWNER, UserRole.ADMIN));

    expect(() => middleware(req, res, next)).toThrow(APIError);
  });

  test('Authorizer', () => {
    const req = getMockReq();
    const { res, next } = getMockRes(response());

    const middleware = Allow((_, __) => true);
    middleware(req, res, next);
    expect(next).toBeCalled();
  });

  test('Authorizer - Fail', () => {
    const req = getMockReq();
    const { res, next } = getMockRes(response());

    const middleware = Allow((_, __) => false);
    expect(() => middleware(req, res, next)).toThrow(APIError);
  });
});
