import { Service } from 'typedi';
import { Account } from '../models/account';
import { BaseDao } from './base';

@Service()
export class AccountDao extends BaseDao<Account> {
  constructor() {
    super('accounts', Account);
  }
}
