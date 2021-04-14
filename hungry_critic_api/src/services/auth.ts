import { Service } from 'typedi';
import { APIError } from '../controllers/middleware/error';
import { FirebaseAuthDao } from '../data/auth';
import { Account, AuthReceipt, Credentials, SignInMethod } from '../models/account';
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
      return this.verifyCreds(account, creds);
    } else {
      return this.createAccount(id, creds);
    }
  }

  private async verifyCreds(account: Account, creds: Credentials): Promise<any> {
    const settings = account.settings;
    if (settings.blocked) throw new APIError('This account has been blocked!');
    const match = await this.hasher.verify(settings.hashedPassword, creds.firebaseId);
    if (!match) {
      await this.markFail(account);
      throw new APIError('The email or password you provided was incorrect');
    }
    if (settings.attempts > 0) return this.resetAttempts(account);
    return this.makeReceipt(account.id, !account.name);
  }

  private async createAccount(id: string, creds: Credentials): Promise<any> {
    this.logger.debug('Creating new account', { accountId: id });
    const success = await this.verify(creds);
    if (!success) throw new APIError('You are not authorized to create this account!', 403);
    const hashedPassword = await this.hasher.withSalt(creds.firebaseId);
    const settings = { blocked: false, attempts: 0, hashedPassword };
    const account = <Account>{ id, method: creds.method, settings };
    await this.service.create(account);
    return this.makeReceipt(id, false);
  }

  private async markFail(account: Account): Promise<any> {
    const settings = account.settings;
    settings.attempts += 1;
    if (settings.attempts === 3) settings.blocked = true;
    return this.service.update(account);
  }

  private async resetAttempts(account: Account): Promise<any> {
    account.settings.attempts = 0;
    return this.service.update(account);
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

  private makeReceipt(id: string, fresh: boolean): AuthReceipt {
    return { id, fresh, token: this.token.create(id) };
  }
}
