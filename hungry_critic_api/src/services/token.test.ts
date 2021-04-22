import { TokenService } from './token';
import { LoggingService } from './logging';
import { UserRole, Account } from '../models/account';
jest.mock('./logging');

describe('Checking all methods', () => {
  test('Create token', () => {
    const service = new TokenService(new LoggingService());
    const token = service.create(<Account>{
      id: 'sample-id',
      role: UserRole.USER,
      email: 'alokraop@gmail.com',
      name: 'Alok',
    });
    expect(token).toBe(
      'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6InNhbXBsZS1pZCIsInJvbGUiOjB9.l_z5KTb7SSkU6ns5WwsoYqv0hR2BH0ZOh-XfjdTVohA',
    );
  });

  test('Verify token', () => {
    const service = new TokenService(new LoggingService());
    const info = service.verify(
      'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6InNhbXBsZS1pZCIsInJvbGUiOjB9.l_z5KTb7SSkU6ns5WwsoYqv0hR2BH0ZOh-XfjdTVohA',
    );
    expect(info?.id).toBe('sample-id');
    expect(info?.role).toBe(0);
  });

  test('Invalid token', () => {
    const service = new TokenService(new LoggingService());
    const value = service.verify('eyJ');
    expect(value).toBe(undefined);
  });
});
