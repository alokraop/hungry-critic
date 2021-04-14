import { Request, Response, NextFunction } from 'express';
import { Container } from 'typedi';
import { TokenService } from '../../services/token';
import { APIError } from './error';

export function Authenticate(req: Request, res: Response, next: NextFunction) {
  const service = Container.get(TokenService);
  const accountId = service.verify(req.headers.token);
  if (!accountId) throw new APIError('Invalid or missing token', 403);
  res.locals = { accountId };
  next();
}
