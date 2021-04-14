import 'express-async-errors';
import 'reflect-metadata';

import express from 'express';
import { setupRoutes } from './router';

import admin from 'firebase-admin';
import root from 'app-root-path';

const account = require(root + '/assets/firebase-private-key.json');
admin.initializeApp({
    credential: admin.credential.cert(account),
});

export function createWebServer() {
  const webServer = express();
  webServer.use(
    express.json({ limit: '5mb' }),
    express.urlencoded({
      limit: '5mb',
      extended: true,
    }),
  );

  setupRoutes(webServer);
  webServer.listen(9999, () => console.log('Running on port 9999'));
}

createWebServer();
