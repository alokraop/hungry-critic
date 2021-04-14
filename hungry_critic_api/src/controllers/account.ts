import { Router, Request, Response } from 'express';

import { Container } from 'typedi';
import { Account } from '../models/account';
import { AccountService } from '../services/account';
import { Validate } from './middleware/validation';

export const accountRouter: Router = Router();

const service = () => Container.get(AccountService);

accountRouter.get('/', async (_: Request, res: Response) => {
    const account = await service().fetch(res.locals.accountId);
    res.json(account);
});

accountRouter.put('/', Validate(Account), async (req: Request, res: Response) => {
    await service().update(req.body);
    res.send();
});
