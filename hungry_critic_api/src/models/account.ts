import { Allow, IsDefined, IsEmail, IsEnum, MinLength } from 'class-validator';
import { HashResult } from './internal';

export enum SignInMethod {
  EMAIL,
  GOOGLE,
  FACEBOOK,
}

export class SignInCredentials {
  @IsDefined()
  identifier: string;

  @IsDefined()
  @MinLength(8)
  firebaseId: string;

}

export class SignUpCredentials extends SignInCredentials {

  @IsDefined()
  @IsEnum(SignInMethod)
  method: SignInMethod;
}
export class Settings {
  providerId: string;

  hashedPassword: HashResult;

  @Allow()
  blocked: boolean;

  attempts: number;

  @Allow()
  initialized: boolean;

  method: SignInMethod;

  constructor(password: HashResult, creds: SignUpCredentials) {
    this.providerId = creds.identifier;
    this.hashedPassword = password;
    this.blocked = false;
    this.attempts = 0;
    this.initialized = false;
    this.method = creds.method;
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
  
  @Allow()
  settings: Settings;
}

export class Account extends Profile {
  @IsEmail()
  email: string;

  @IsDefined()
  @IsEnum(UserRole)
  role: UserRole;
}

export interface AuthReceipt {
  id: string;

  token: string;

}
