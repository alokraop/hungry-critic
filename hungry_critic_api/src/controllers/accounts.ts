import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { Account, Profile } from '../models/account';
import { PageInfo } from '../models/internal';
import { AccountService } from '../services/accounts';
import { AuthService } from '../services/auth';
import { Validate } from './middleware/validation';

export const accountRouter: Router = Router();

const service = () => Container.get(AccountService);
const aService = () => Container.get(AuthService);

accountRouter.get('/', async (req: Request, res: Response) => {
  const account = await service().fetchAll(res.locals.info, new PageInfo(req.query));
  res.json(account);
});

accountRouter.get('/:id', async (req: Request, res: Response) => {
  const account = await service().fetchExternal(req.params.id);
  res.json(account);
});

accountRouter.post('/', Validate(Account), async (req: Request, res: Response) => {
  const receipt = await service().createProfile(req.body, res.locals.info);
  res.json(receipt);
});

accountRouter.put('/:id', Validate(Account), async (req: Request, res: Response) => {
  await service().updateAccount(req.params.id, req.body, res.locals.info);
  res.send();
});

accountRouter.delete('/:id', async (req: Request, res: Response) => {
  const token = await aService().deleteAccount(req.params.id, res.locals.info);
  res.send({ token });
});
