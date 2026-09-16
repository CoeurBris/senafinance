"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.objectifRoutes = void 0;
const objectif_controller_1 = require("../controller/objectif.controller");
const objectifRoutes = (router) => {
    router.post('/api/objectifs', objectif_controller_1.createObjectif);
    router.get('/api/objectifs/all', objectif_controller_1.getAllObjectifs);
    router.get('/api/objectifs', objectif_controller_1.getObjectifsPaginated);
    router.get('/api/objectifs/:id/versements', objectif_controller_1.getVersementsByObjectif);
    router.get('/api/objectifs/:id', objectif_controller_1.getObjectifById);
    router.put('/api/objectifs/:id', objectif_controller_1.updateObjectif);
    router.patch('/api/objectifs/:id/montant', objectif_controller_1.addMontantObjectif);
    router.delete('/api/objectifs/:id', objectif_controller_1.deleteObjectif);
};
exports.objectifRoutes = objectifRoutes;
