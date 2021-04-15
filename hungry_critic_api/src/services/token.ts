import jwt from 'jsonwebtoken';
import { Service } from 'typedi';
import config from 'config';
import { LoggingService } from './logging';
import { TokenInfo } from '../models/internal';

@Service()
export class TokenService {
  constructor(private logger: LoggingService) {}

  create(info: TokenInfo): string {
    return jwt.sign(JSON.stringify(info), config.get<string>('auth.key'));
  }

  verify(token: any): TokenInfo | undefined {
    if (!token || typeof token !== 'string') return;
    try {
      const json = jwt.verify(token, config.get<string>('auth.key'), {});
      if (json && typeof json == 'object') {
        return json as TokenInfo;
      }
    } catch (e) {
      this.logger.warn(`Token verification failed: ${e}`);
    }
  }
}
