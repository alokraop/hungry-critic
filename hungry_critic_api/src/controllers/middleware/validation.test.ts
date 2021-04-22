import { getMockReq, getMockRes } from '@jest-mock/express';
import { Account, UserRole } from '../../models/account';
import { Validate } from './validation';

describe('Validating Account', () => {
  test('Valid', async () => {
    const validator = Validate(Account);
    const account = <Account>{
      id: 'some-id',
      email: 'abc@example.com',
      role: UserRole.USER,
      name: 'some-user',
    };
    const req = getMockReq({
      body: account,
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    expect(next).toBeCalled();
  });

  test('Missing field', async () => {
    const validator = Validate(Account);
    const req = getMockReq({
      body: {
        id: 'some-id',
        email: 'abc@example.com',
        name: 'some-user',
      },
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    const errors = [expect.objectContaining({ property: 'role' })];
    expect(next).toBeCalledWith(expect.arrayContaining(errors));
  });

  test('Invalid value', async () => {
    const validator = Validate(Account);
    const req = getMockReq({
      body: { id: 'some-id', email: 'abc@example.com', role: 6, name: 'some-user' },
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    const errors = [
      expect.objectContaining({
        property: 'role',
        constraints: { isEnum: 'role must be a valid enum value' },
      }),
    ];
    expect(next).toBeCalledWith(expect.arrayContaining(errors));
  });

  test('Multiple fields', async () => {
    const validator = Validate(Account);
    const req = getMockReq({
      body: {
        email: 'abcd',
        name: 'some-name',
      },
    });
    const { res, next } = getMockRes();
    await validator(req, res, next);

    const errors = [
      expect.objectContaining({ property: 'role' }),
      expect.objectContaining({ property: 'email' }),
    ];
    expect(next).toBeCalledWith(expect.arrayContaining(errors));
  });
});
