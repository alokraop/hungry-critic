import { Router, Request, Response } from 'express';
import { Credentials } from '../models/account';
import { Validate } from './middleware/validation';
import { Container } from 'typedi';
import { AuthService } from '../services/auth';

export const authRouter: Router = Router();

const service = () => Container.get(AuthService);

authRouter.post('/', Validate(Credentials), async (req: Request, res: Response) => {
  const receipt = await service().signIn(req.body);
  res.status(201).json(receipt);
});
