import { Request, Response, NextFunction } from 'express';
import { Account, UserRole } from '../../models/account';
import { TokenInfo } from '../../models/internal';
import { APIError } from './error';

type Authorizer = (req: Request, res: Response) => boolean;

export function Allow(...predicates: Authorizer[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    for (const predicate of predicates) {
      const allow = predicate(req, res);
      if (allow) {
        next();
        return;
      }
    }
    throw new APIError('Your role does not have priviledges to call this endpoint!', 403);
  };
}

export function Roles(...roles: UserRole[]) {
  return (_: Request, res: Response): boolean => {
    const caller: TokenInfo = res.locals.info;
    return roles.some((r) => r === caller.role);
  };
}

export function AllowSelf(req: Request, res: Response): boolean {
  const body = req.body;
  const caller: TokenInfo = res.locals.info;

  return body instanceof Account && body.id === caller.id;
}

export function AllowSelfParam(req: Request, res: Response): boolean {
  const caller: TokenInfo = res.locals.info;
  return req.params.id === caller.id;
}
