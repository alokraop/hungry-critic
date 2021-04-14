import { HashingService } from './hash';
import { LoggingService } from './logging';
jest.mock('./logging');

describe('Both ways', () => {
  test('Hashing and verifying', async () => {
    const hash = new HashingService(new LoggingService());
    const result = await hash.withSalt('password');
  
    const success = await hash.verify(result, 'password');
    expect(success).toBe(true);
  });

  test('Failed verification', async () => {
    const hash = new HashingService(new LoggingService());
    const result = await hash.withSalt('password');
  
    const success = await hash.verify(result, 'else');
    expect(success).toBe(false);
  });
});
