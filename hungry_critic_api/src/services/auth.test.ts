import { AccountDao } from '../data/accounts';
import { FirebaseAuthDao } from '../data/auth';
import { Account, SignUpCredentials } from '../models/account';
import { HashResult } from '../models/internal';
import { AccountService } from './accounts';
import { AuthService } from './auth';
import { HashingService } from './hash';
import { LoggingService } from './logging';
import { RestaurantService } from './restaurants';
import { TokenService } from './token';
jest.mock('../data/auth');
jest.mock('./account');
jest.mock('../data/accounts');
jest.mock('./hash');
jest.mock('./logging');
jest.mock('./token');

const creds = <SignUpCredentials>{
  identifier: 'abcd@example.com',
  firebaseId: '6f1C6GmQLoNL3gfdKH5jUth9Kw83',
};

describe('Sign up tests', () => {
  let service: AuthService;

  beforeAll(() => {
    const create = TokenService.prototype.create as jest.Mock;
    create.mockImplementation((_: string) => 'some-token');

    const dao = new FirebaseAuthDao();
    const logger = new LoggingService();
    const token = new TokenService(logger);
    const aService = new AccountService(new AccountDao(), token, <RestaurantService>{});
    const hasher = new HashingService(logger);
    service = new AuthService(dao, aService, logger, token, hasher);
  });

  test('New Account', async () => {
    const fetch = AccountService.prototype.fetchInternal as jest.Mock;
    fetch.mockImplementation((_: string) => undefined);
    const token = await service.signIn(creds);
    expect(token).toBe('some-token');
    expect(fetch).toBeCalledTimes(1);
  });
});

describe('Sign in tests', () => {
  let service: AuthService;

  beforeAll(() => {
    const create = TokenService.prototype.create as jest.Mock;
    create.mockImplementation((_: string) => 'some-token');

    const fetch = AccountService.prototype.fetchInternal as jest.Mock;
    fetch.mockImplementation((_: string) => {
      return <Account>{
        id: 'some-id',
        settings: {
          hashedPassword: {
            cipher: 'some-cipher',
            salt: 'some-salt',
          },
        },
      };
    });

    const dao = new FirebaseAuthDao();
    const logger = new LoggingService();
    const token = new TokenService(logger);
    const aService = new AccountService(new AccountDao(), token, <RestaurantService>{});
    const hasher = new HashingService(logger);
    service = new AuthService(dao, aService, logger, token, hasher);
  });

  test('Successful', async () => {
    const verify = HashingService.prototype.verify as jest.Mock;
    verify.mockImplementation((_: HashResult, __: string) => true);

    const token = await service.signIn(creds);
    expect(token).toBe('some-token');

    expect(verify).toBeCalledTimes(1);
  });

  test('Incorrect password', async () => {
    const verify = HashingService.prototype.verify as jest.Mock;
    verify.mockClear();
    verify.mockImplementation((_: HashResult, __: string) => false);
    try {
      await service.signIn(creds);
    } catch (e) {
      expect(e.message).toBe('The email or password you provided was incorrect');
    }
    expect(verify).toBeCalledTimes(1);
  });
});
