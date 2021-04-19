import { Service } from 'typedi';
import { APIError } from '../controllers/middleware/error';
import { AccountDao } from '../data/accounts';
import { Account, AuthReceipt, Profile, Settings, UserRole } from '../models/account';
import { TokenInfo } from '../models/internal';
import { TokenService } from './token';

@Service()
export class AccountService {
  constructor(private dao: AccountDao, private token: TokenService) {}

  async fetchAll(caller: TokenInfo): Promise<Account[]> {
    if (caller.role !== UserRole.ADMIN) {
      throw new Error("You don't have priviledges to view all users");
    }
    return this.dao.findAll({}, { 'settings.hashedPassword': 0 });
  }

  async fetchExternal(id: string): Promise<Account | null> {
    return this.dao.fetch(id, { _id: 0, 'settings.hashedPassword': 0 });
  }

  async fetchInternal(id: string): Promise<Account | null> {
    return this.dao.fetch(id);
  }

  async create(account: Account): Promise<any> {
    return this.dao.save(account);
  }

  async createProfile(account: Account, caller: TokenInfo): Promise<AuthReceipt> {
    if (caller.id !== account.id) {
      throw new APIError("You don't have priviledges to modify this account!", 403);
    }
    const existing = await this.dao.fetch(account.id);
    if (!existing) throw new APIError("Can't create a profile before creating the account!");
    if (existing.settings.initialized) throw new APIError('Profile exists!!');
    await this.dao.update(
      { id: account.id },
      {
        ...account,
        settings: { ...existing.settings, initialized: account.role !== UserRole.ADMIN },
      },
    );
    return { id: account.id, token: this.token.create(account) };
  }

  async updateProfile(id: string, profile: Profile, caller: TokenInfo): Promise<string> {
    if (id !== caller.id && caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to modify this account!");
    }
    return this.dao.update({ id }, profile);
  }

  async updateAttempts(id: string, caller: TokenInfo): Promise<any> {
    if (id !== caller.id) {
      throw new APIError("You don't have priviledges to modify this account!");
    }
    const account = await this.dao.fetch(id);
    if (!account) throw new APIError('This account does not exist');
    if (account.settings.blocked) throw new APIError("Can't modify blocked account!");
    return this.markFail(account);
  }

  async updateAccount(id: string, account: Account, caller: TokenInfo): Promise<string> {
    if (caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to modify this account!");
    }
    const { settings, ...fields } = account;
    return this.dao.update({ id }, { ...fields, ...this.flatten(settings) });
  }

  async markFail(account: Account): Promise<any> {
    const settings = account.settings;
    settings.attempts += 1;
    if (settings.attempts === 3) {
      settings.blocked = true;
      settings.attempts = 0;
    }
    return this.updateSettings(account.id, settings);
  }

  async resetAttempts(account: Account): Promise<any> {
    account.settings.attempts = 0;
    return this.updateSettings(account.id, account.settings);
  }

  async updateSettings(id: string, settings: Settings): Promise<any> {
    return this.dao.update({ id }, { settings });
  }

  async delete(id: string, caller: TokenInfo): Promise<any> {
    //TODO: Delete all relevant restaurants/reviews
    throw new Error('Method not implemented.');
  }

  private flatten(settings: Settings) {
    return {
      'settings.blocked': settings.blocked,
      'settings.initialized': settings.initialized,
    };
  }
}
