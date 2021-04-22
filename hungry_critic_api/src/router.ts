import { Express } from 'express';
import morgan from 'morgan';
import Container from 'typedi';
import { accountRouter } from './controllers/accounts';
import { authRouter } from './controllers/auth';
import { HandleErrors } from './controllers/middleware/error';
import { Authenticate } from './controllers/middleware/authenticate';
import { LoggingService } from './services/logging';
import { restaurantRouter } from './controllers/restaurants';
import { reviewRouter } from './controllers/pending_reviews';

export function setupRoutes(webServer: Express) {
  const logger = Container.get(LoggingService);
  webServer.use(
    morgan(':method :url :status ":user-agent" :response-time ms', {
      stream: { write: (log) => logger.info(log) },
    }),
  );
  webServer.use('/auth', authRouter);
  webServer.use('/accounts', Authenticate, accountRouter);
  webServer.use('/restaurants', Authenticate, restaurantRouter);
  webServer.use('/reviews', Authenticate, reviewRouter);
  webServer.use(HandleErrors);
}
