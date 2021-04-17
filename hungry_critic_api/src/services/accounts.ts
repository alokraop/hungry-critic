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
    return this.dao.fetch(id, { _id: 0, settings: 0 });
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
      { ...account, settings: { ...existing.settings, initialized: true } },
    );
    return { id: account.id, token: this.token.create(account), fresh: false };
  }

  async update(id: string, profile: Profile, caller: TokenInfo): Promise<string> {
    if (id !== caller.id && caller.role !== UserRole.ADMIN) {
      throw new APIError("You don't have priviledges to modify this account!");
    }
    return this.dao.update({ id }, profile);
  }

  async updateSettings(id: string, settings: Settings): Promise<any> {
    return this.dao.update({ id }, { settings });
  }

  async delete(id: string, caller: TokenInfo): Promise<any> {
    //TODO: Delete all relevant restaurants/reviews
    throw new Error('Method not implemented.');
  }
}
