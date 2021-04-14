import { validate, ValidatorOptions } from 'class-validator';
import { ClassConstructor, plainToClass } from 'class-transformer';
import { NextFunction, Request, Response } from 'express';

export function Validate<T extends Object>(type: ClassConstructor<T>) {
    return async (req: Request, _: Response, next: NextFunction) => {
        const entity = plainToClass(type, req.body);
        const errors = await validate(entity, <ValidatorOptions>{
            skipMissingProperties: true,
            whitelist: true,
            validationError: { target: false, value: false },
        });
        if (errors.length > 0) {
            next(errors);
        } else {
            req.body = entity;
            next();
        }
    };
}
