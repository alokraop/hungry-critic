import { Router, Request, Response } from 'express';
import { SignInCredentials, SignUpCredentials } from '../models/account';
import { Validate } from './middleware/validation';
import { Container } from 'typedi';
import { AuthService } from '../services/auth';

export const authRouter: Router = Router();

const service = () => Container.get(AuthService);

authRouter.post('/sign-up', Validate(SignUpCredentials), async (req: Request, res: Response) => {
  const receipt = await service().signUp(req.body);
  res.status(201).json(receipt);
});

authRouter.post('/sign-in', Validate(SignInCredentials), async (req: Request, res: Response) => {
  const receipt = await service().signIn(req.body);
  res.json(receipt);
});
