import jwt from 'jsonwebtoken';
import { Service } from 'typedi';
import config from 'config';
import { LoggingService } from './logging';

@Service()
export class TokenService {
  constructor(private logger: LoggingService) {}

  create(value: string): string {
    return jwt.sign(value, config.get<string>('auth.key'));
  }

  verify(token: any): string | undefined {
    if (!token || typeof token !== 'string') return;
    try {
      const accountId = jwt.verify(token, config.get<string>('auth.key'), {});
      if (accountId && typeof accountId == 'string') {
        return accountId;
      }
    } catch (e) {
      this.logger.warn(`Token verification failed: ${e}`);
    }
  }
}
