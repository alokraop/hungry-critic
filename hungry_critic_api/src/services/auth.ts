import { Service } from 'typedi';
import { APIError } from '../controllers/middleware/error';
import { FirebaseAuthDao } from '../data/auth';
import {
  Account,
  AuthReceipt,
  Credentials,
  Settings,
  SignInMethod,
  UserRole,
} from '../models/account';
import { TokenInfo } from '../models/internal';
import { AccountService } from './accounts';
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

  async signUp(creds: Credentials): Promise<string> {
    const id = this.hasher.simple(creds.identifier);
    const account = await this.service.fetchInternal(id);
    if (account) throw new APIError('An account with this identifier already exists!');
    return this.createAccount(id, creds);
  }

  async signIn(creds: Credentials): Promise<string> {
    const id = this.hasher.simple(creds.identifier);
    const account = await this.service.fetchInternal(id);
    if (!account) throw new APIError("Can't sign into a non-existent account!");
    return this.verifyCreds(account, creds);
  }

  private async createAccount(id: string, creds: Credentials): Promise<any> {
    this.logger.debug('Creating new account', { accountId: id });
    const success = await this.verify(creds);
    if (!success) throw new APIError('You are not authorized to create this account!', 403);
    const hashedPassword = await this.hasher.withSalt(creds.firebaseId);
    const account = <Account>{
      id,
      role: UserRole.CUSTOMER,
      settings: new Settings(hashedPassword, creds.method),
    };
    await this.service.create(account);
    return this.makeReceipt(account);
  }

  private async verifyCreds(account: Account, creds: Credentials): Promise<any> {
    const settings = account.settings;
    if (settings.blocked) throw new APIError('This account has been blocked!', 412);
    const match = await this.hasher.verify(settings.hashedPassword, creds.firebaseId);
    if (!match) {
      await this.service.markFail(account);
      throw new APIError('The email or password you provided was incorrect', 403);
    }
    if (settings.attempts > 0) return this.service.resetAttempts(account);
    return this.makeReceipt(account);
  }

  async verify(creds: Credentials): Promise<boolean> {
    const record = await this.dao.fetchRecord(creds.firebaseId);
    switch (creds.method) {
      case SignInMethod.EMAIL:
        //TODO: Better verification once start using firebase email on app
        return record.emailVerified && record.email === creds.identifier;
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

  private makeReceipt(account: Account): AuthReceipt {
    return { id: account.id, token: this.token.create(account) };
  }
}
