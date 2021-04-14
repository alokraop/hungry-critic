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

export class Account {
  @Allow()
  id: string;

  hashedPassword: HashResult;

  @Allow()
  blocked: boolean;

  @ValidateNested()
  @Type(() => Credentials)
  creds: Credentials;
  
  @ValidateNested()
  @Type(() => UserProfile)
  profile: UserProfile;
}

export enum UserRole { CUSTOMER, OWNER, ADMIN }

export class UserProfile {

  @IsDefined()
  id: string;

  @Allow()
  name: string;

  @IsEmail()
  email: string;

  @IsDefined()
  @IsEnum(UserRole)
  role: UserRole;

}
