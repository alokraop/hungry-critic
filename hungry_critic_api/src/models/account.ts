import { Allow, IsDefined, IsEmail, IsEnum, MinLength } from 'class-validator';
import { HashResult } from './internal';

export enum SignInMethod {
  EMAIL,
  GOOGLE,
  FACEBOOK,
}

export class Credentials {
  @IsDefined()
  identifier: string;

  @IsDefined()
  @MinLength(8)
  firebaseId: string;

  @IsDefined()
  @IsEnum(SignInMethod)
  method: SignInMethod;
}

export class Settings {
  hashedPassword: HashResult;

  blocked: boolean;

  attempts: number;

  initialized: boolean;

  method: SignInMethod;

  constructor(password: HashResult, method: SignInMethod) {
    this.hashedPassword = password;
    this.blocked = false;
    this.attempts = 0;
    this.initialized = false;
    this.method = method;
  }
}

export enum UserRole {
  CUSTOMER,
  OWNER,
  ADMIN,
}

export class Profile {
  @Allow()
  id: string;

  @Allow()
  name: string;
}

export class Account extends Profile {
  @IsEmail()
  email: string;

  @IsDefined()
  @IsEnum(UserRole)
  role: UserRole;
  
  settings: Settings;
}

export interface AuthReceipt {
  id: string;

  token: string;

  fresh: boolean;
}
