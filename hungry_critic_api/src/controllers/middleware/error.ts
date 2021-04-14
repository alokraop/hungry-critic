import { ValidationError } from 'class-validator';
import { NextFunction, Request, Response } from 'express';
import Container from 'typedi';
import { LoggingService } from '../../services/logging';

export class APIError extends Error {
  status: number;
  text: string;

  data: any;

  constructor(message: string, status: number = 400, data: any = {}) {
    super(message);
    this.status = status;
    this.text = message;
    this.data = data;
    Object.setPrototypeOf(this, APIError.prototype);
  }
}

export function HandleErrors(err: Error | Array<any>, _: Request, res: Response, __: NextFunction) {
  const logger = Container.get(LoggingService);
  if (err instanceof Error) {
    logger.error(`Error message: ${err.message}`);
    if (err.stack) logger.error(err.stack);
  }

  if (err instanceof APIError) {
    const error = err as APIError;
    res.status(error.status).json({ message: error.text, ...error.data });
  } else if (err instanceof Array && err[0] instanceof ValidationError) {
    res.status(422).json({ errors: err });
  } else {
    res.status(500).json({ message: 'Unexpected error!' });
  }
}
