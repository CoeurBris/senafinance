import * as express from 'express';
//import { checkPermission } from '../../../middlewares/auth.middleware';
import { getAllJournalConnexions, getAllJournalOperations } from '../controller/journal.controller';
import { checkPermission } from '../../../middlewares/auth.middleware';

export  const journalRoutes =  (router: express.Router) => {
  // router.get('/api/journalConnexions',checkPermission('JournalConnexions'), getAllJournalConnexions);
  // router.get('/api/journalOperations',checkPermission('JournalOperations'), getAllJournalOperations);

 router.get('/api/journalConnexions',getAllJournalConnexions);
 router.get('/api/journalOperations',getAllJournalOperations);

};