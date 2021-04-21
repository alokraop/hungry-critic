import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { Account, Profile, UserRole } from '../models/account';
import { PageInfo } from '../models/internal';
import { AccountService } from '../services/accounts';
import { AuthService } from '../services/auth';
import { Roles, AllowSelf, AllowSelfParam, Allow } from './middleware/authorize';
import { Validate } from './middleware/validation';

export const accountRouter: Router = Router();

const service = () => Container.get(AccountService);
const aService = () => Container.get(AuthService);

accountRouter.get(
  '/',
  Allow(Roles(UserRole.ADMIN)),
  async (req: Request, res: Response) => {
    const account = await service().fetchAll(new PageInfo(req.query));
    res.json(account);
  },
);

accountRouter.get('/:id', Allow(AllowSelfParam), async (req: Request, res: Response) => {
  const account = await service().fetchExternal(req.params.id);
  res.json(account);
});

accountRouter.post(
  '/',
  Validate(Account),
  Allow(AllowSelf),
  async (req: Request, res: Response) => {
    const receipt = await service().createProfile(req.body);
    res.json(receipt);
  },
);

accountRouter.put(
  '/:id',
  Validate(Profile),
  Allow(Roles(UserRole.ADMIN), AllowSelfParam),
  async (req: Request, res: Response) => {
    await service().updateProfile(req.params.id, req.body, res.locals.info);
    res.send();
  },
);

accountRouter.delete(
  '/:id',
  Allow(Roles(UserRole.ADMIN)),
  async (req: Request, res: Response) => {
    const token = await aService().deleteAccount(req.params.id);
    res.send({ token });
  },
);
