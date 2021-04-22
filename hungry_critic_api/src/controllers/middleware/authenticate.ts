import { Request, Response, NextFunction } from 'express';
import { Container } from 'typedi';
import { TokenService } from '../../services/token';
import { APIError } from './error';

export function Authenticate(req: Request, res: Response, next: NextFunction) {
  const service = Container.get(TokenService);
  const info = service.verify(req.headers.token);
  if (!info) throw new APIError('Invalid or missing token', 403);
  res.locals = { info };
  next();
}
