import { Type } from 'class-transformer';
import { Allow, IsDefined, IsEmail, IsEnum, MinLength, ValidateNested } from 'class-validator';
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

  @Allow()
  blocked: boolean;

  @Allow()
  attempts: number;
}

export enum UserRole {
  CUSTOMER,
  OWNER,
  ADMIN,
}

export class Account {
  @Allow()
  id: string;

  @Allow()
  name: string;

  @IsEmail()
  email: string;

  @IsDefined()
  @IsEnum(UserRole)
  role: UserRole;
  
  @IsDefined()
  @IsEnum(SignInMethod)
  method: SignInMethod;
  
  @Allow()
  settings: Settings;
}

export interface AuthReceipt {
  id: string;

  token: string;

  fresh: boolean;
}
