import { TokenService } from './token';
import { LoggingService } from './logging';
jest.mock('./logging');

describe('Checking all methods', () => {
  test('Create token', () => {
    const service = new TokenService(new LoggingService());
    const token = service.create('sample-id');
    expect(token).toBe(
      'eyJhbGciOiJIUzI1NiJ9.c2FtcGxlLWlk.Ehi6ID6CdSwQqE1LGJqMBbnuFK0Mc5udnvPcBkxGJeg',
    );
  });

  test('Verify token', () => {
    const service = new TokenService(new LoggingService());
    const value = service.verify('eyJhbGciOiJIUzI1NiJ9.c2FtcGxlLWlk.Ehi6ID6CdSwQqE1LGJqMBbnuFK0Mc5udnvPcBkxGJeg');
    expect(value).toBe('sample-id');
  });

  test('Invalid token', () => {
    const service = new TokenService(new LoggingService());
    const value = service.verify('eyJ');
    expect(value).toBe(undefined);
  });
});
