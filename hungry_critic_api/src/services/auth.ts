import { Service } from 'typedi';
import { APIError } from '../controllers/middleware/error';
import { FirebaseAuthDao } from '../data/auth';
import { Account, Credentials, SignInMethod } from '../models/account';
import { AccountService } from './account';
import { HashingService } from './hash';
import { LoggingService } from './logging';
import { TokenService } from './token';

@Service()
export class AuthService {
  constructor(
    private dao: FirebaseAuthDao,
    private service: AccountService,
    private logger: LoggingService,
    private token: TokenService,
    private hasher: HashingService,
  ) {}

  async signIn(creds: Credentials): Promise<string> {
    const id = this.hasher.simple(creds.identifier);
    const account = await this.service.fetch(id);
    if (account) {
      const same = await this.hasher.verify(account.hashedPassword, creds.firebaseId);
      if (!same) throw new APIError('The email or password you provided was incorrect');
    } else {
      this.logger.debug('Creating new account', { accountId: id });
      const success = await this.verify(creds);
      if (!success) throw new APIError('You are not authorized to create this account!', 403);
      const hashedPassword = await this.hasher.withSalt(creds.firebaseId);
      const account = <Account>{ id, hashedPassword, creds, blocked: false };
      await this.service.create(account);
    }
    return this.token.create(id);
  }

  async verify(creds: Credentials): Promise<boolean> {
    const record = await this.dao.fetchRecord(creds.firebaseId);
    switch (creds.method) {
      case SignInMethod.EMAIL:
        //TODO: Better verification once start using firebase email on app
        record.emailVerified && record.email === creds.identifier;
      case SignInMethod.GOOGLE:
        return record.providerData
          .filter((i) => i.providerId === 'google.com')
          .some((i) => i.uid === creds.identifier);
      case SignInMethod.FACEBOOK:
        return record.providerData
          .filter((i) => i.providerId === 'facebook.com')
          .some((i) => i.uid === creds.identifier);
    }
  }
}
