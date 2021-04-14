import { Service } from 'typedi';
import { AccountDao } from '../data/accounts';
import { Account } from '../models/account';

@Service()
export class AccountService {
  constructor(private dao: AccountDao) {}

  async idExists(id: string): Promise<boolean> {
    const account = await this.fetch(id);
    return !!account;
  }

  async fetch(id: string): Promise<Account> {
    return this.dao.fetch(id, { hashedPassword: 0 });
  }

  async create(account: Account): Promise<any> {
    return this.dao.save(account);
  }

  async update(account: Account): Promise<any> {
    return this.dao.update({ id: account.id }, account);
  }
}
