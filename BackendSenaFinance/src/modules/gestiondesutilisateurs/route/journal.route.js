"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.journalRoutes = void 0;
//import { checkPermission } from '../../../middlewares/auth.middleware';
const journal_controller_1 = require("../controller/journal.controller");
const journalRoutes = (router) => {
    // router.get('/api/journalConnexions',checkPermission('JournalConnexions'), getAllJournalConnexions);
    // router.get('/api/journalOperations',checkPermission('JournalOperations'), getAllJournalOperations);
    router.get('/api/journalConnexions', journal_controller_1.getAllJournalConnexions);
    router.get('/api/journalOperations', journal_controller_1.getAllJournalOperations);
};
exports.journalRoutes = journalRoutes;
