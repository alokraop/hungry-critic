import { getMockReq, getMockRes } from '@jest-mock/express';
import { Account } from '../../models/account';
import { Validate } from './validation';

describe('Validating Account', () => {
  test('Valid', async () => {
    const validator = Validate(Account);
    const account = {
      id: 'some-id',
      email: 'abcd@example.com',
      password: 'password',
    };
    const req = getMockReq({
      body: account,
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    expect(next).toBeCalledWith();
  });

  test('Missing field', async () => {
    const validator = Validate(Account);
    const req = getMockReq({
      body: {
        email: 'abcd@example.com',
        password: 'password',
      },
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    const errors = [expect.objectContaining({ property: 'id' })];
    expect(next).toBeCalledWith(expect.arrayContaining(errors));
  });

  test('Invalid value', async () => {
    const validator = Validate(Account);
    const req = getMockReq({
      body: {
        id: 'some-id',
        email: 'abcd',
        username: 'some-name',
      },
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    const errors = [
      expect.objectContaining({
        property: 'email',
        constraints: { isEmail: 'email must be an email' },
      }),
    ];
    expect(next).toBeCalledWith(expect.arrayContaining(errors));
  });

  test('Multiple fields', async () => {
    const validator = Validate(Account);
    const req = getMockReq({
      body: {
        email: 'abcd',
        username: 'some-name',
      },
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    const errors = [
      expect.objectContaining({ property: 'id' }),
      expect.objectContaining({ property: 'email' }),
    ];
    expect(next).toBeCalledWith(expect.arrayContaining(errors));
  });
});
