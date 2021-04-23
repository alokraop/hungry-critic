import { Request, Response, NextFunction } from 'express';
import { Container } from 'typedi';
import { BlockService } from '../../services/block';
import { TokenService } from '../../services/token';
import { APIError } from './error';

export function Authenticate(req: Request, res: Response, next: NextFunction) {
  const service = Container.get(TokenService);
  const info = service.verify(req.headers.token);
  if (!info) throw new APIError('Invalid or missing token', 403);

  const bService = Container.get(BlockService);
  if(bService.isBlocked(info.id)) throw new APIError('This account is blocked!', 412);
  res.locals = { info };
  next();
}
