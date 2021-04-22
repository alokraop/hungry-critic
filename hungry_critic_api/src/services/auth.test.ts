import { auth } from 'firebase-admin';
import { AccountDao } from '../data/accounts';
import { FirebaseAuthDao } from '../data/auth';
import { Account, SignInMethod, SignUpCredentials } from '../models/account';
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

describe('Sign up tests', () => {
  let service: AuthService;

  beforeAll(() => {
    const create = TokenService.prototype.create as jest.Mock;
    create.mockImplementation((_: Account) => 'some-token');

    const simple = HashingService.prototype.simple as jest.Mock;
    simple.mockImplementation((s: string) => 'some-id');

    const logger = new LoggingService();
    const token = new TokenService(logger);
    const dao = new FirebaseAuthDao();
    const aService = new AccountService(new AccountDao(), token, <RestaurantService>{});
    const hasher = new HashingService(logger);
    service = new AuthService(dao, aService, logger, token, hasher);
  });

  test('New Email Account', async () => {
    const creds = <SignUpCredentials>{
      identifier: 'abcd@example.com',
      firebaseId: '6f1C6GmQLoNL3gfdKH5jUth9Kw83',
      method: SignInMethod.EMAIL,
    };

    const record = FirebaseAuthDao.prototype.fetchRecord as jest.Mock;
    record.mockImplementation((uid: string) => {
      return <auth.UserRecord>{
        uid,
        emailVerified: true,
        email: 'abcd@example.com',
      };
    });

    const fetch = AccountService.prototype.fetchInternal as jest.Mock;
    fetch.mockImplementation((_: string) => undefined);

    const token = await service.signUp(creds);
    expect(token).toBe('some-token');
    expect(fetch).toBeCalledTimes(1);
  });
});
