import config from 'config';
import { join } from 'path';
import { Service } from 'typedi';
import { createLogger, format, transports, Logger } from 'winston';
import { TransformableInfo } from 'logform';
import 'winston-daily-rotate-file';

@Service()
export class LoggingService {
  logger: Logger;

  constructor() {
    function formatInfo(i: TransformableInfo): string {
      const basic = `${i.timestamp}\t${i.level.padEnd(7)}`;
      return `${basic}\t${(i?.accountId ?? '').padEnd(20)}\t${i.message}`;
    }

    this.logger = createLogger({
      level: config.get<string>('log.level'),
      format: format.combine(format.timestamp(), format.printf(formatInfo)),
      transports: [
        new transports.Console(),
        new transports.DailyRotateFile({
          filename: '%DATE%.log',
          level: config.get<string>('log.level'),
          datePattern: 'Do_MMMM_YYYY',
          dirname: join(__dirname, '..', '..', 'logs'),
          maxSize: '3m',
          maxFiles: '30d',
        }),
      ],
    });
  }

  debug(message: string, context: any = {}) {
    this.logger.debug(message, context);
  }

  verbose(message: string, context: any = {}) {
    this.logger.verbose(message, context);
  }

  info(message: string, context: any = {}) {
    this.logger.info(message, context);
  }

  warn(message: string, context: any = {}) {
    this.logger.warn(message, context);
  }

  error(message: string, context: any = {}) {
    this.logger.error(message, context);
  }
}
