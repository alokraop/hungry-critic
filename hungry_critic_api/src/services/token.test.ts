import { TokenService } from './token';
import { LoggingService } from './logging';
import { UserRole } from '../models/account';
jest.mock('./logging');

describe('Checking all methods', () => {
  test('Create token', () => {
    const service = new TokenService(new LoggingService());
    const token = service.create({ id: 'sample-id', role: UserRole.CUSTOMER });
    expect(token).toBe(
      'eyJhbGciOiJIUzI1NiJ9.c2FtcGxlLWlk.Ehi6ID6CdSwQqE1LGJqMBbnuFK0Mc5udnvPcBkxGJeg',
    );
  });

  test('Verify token', () => {
    const service = new TokenService(new LoggingService());
    const value = service.verify(
      'eyJhbGciOiJIUzI1NiJ9.c2FtcGxlLWlk.Ehi6ID6CdSwQqE1LGJqMBbnuFK0Mc5udnvPcBkxGJeg',
    );
    expect(value).toBe('sample-id');
  });

  test('Invalid token', () => {
    const service = new TokenService(new LoggingService());
    const value = service.verify('eyJ');
    expect(value).toBe(undefined);
  });
});
