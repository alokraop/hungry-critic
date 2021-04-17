import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { Account, Profile } from '../models/account';
import { AccountService } from '../services/accounts';
import { Validate } from './middleware/validation';

export const accountRouter: Router = Router();

const service = () => Container.get(AccountService);

accountRouter.get('/', async (_: Request, res: Response) => {
  const account = await service().fetchAll(res.locals.info);
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

accountRouter.put('/:id', Validate(Profile), async (req: Request, res: Response) => {
  await service().update(req.params.id, req.body, res.locals.info);
  res.send();
});

accountRouter.delete('/:id', async (req: Request, res: Response) => {
  const token = await service().delete(req.params.id, res.locals.info);
  res.send({ token });
});
