import { UserRole } from './account';

export class HashResult {
  constructor(public cipher: string, public salt: string) {}
}

export interface TokenInfo {
  id: string;

  role: UserRole;
}

export class PageInfo {
  offset: number;

  limit: number;

  constructor(params?: any) {
    this.offset = parseInt(params?.['offset']) ?? 0;
    if (this.offset < 0) this.offset = 0;
    this.limit = parseInt(params?.['limit']) ?? 10;
    if (this.limit < 0) this.limit = 0;
  }
}
