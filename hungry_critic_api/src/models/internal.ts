import { UserRole } from './account';

export class HashResult {
  constructor(public cipher: string, public salt: string) {}
}

export interface TokenInfo {
  id: string;

  role: UserRole;
}
