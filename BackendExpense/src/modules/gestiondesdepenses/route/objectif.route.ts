import { Router } from 'express';
import {
  createObjectif,
  deleteObjectif,
  getAllObjectifs,
  getObjectifById,
  updateObjectif,
  getObjectifsPaginated,
  addMontantObjectif,
  getVersementsByObjectif
} from '../controller/objectif.controller';

export const objectifRoutes = (router: Router) => {
  router.post('/api/objectifs', createObjectif);
  router.get('/api/objectifs/all', getAllObjectifs);
  router.get('/api/objectifs', getObjectifsPaginated);
  router.get('/api/objectifs/:id/versements', getVersementsByObjectif);

  router.get('/api/objectifs/:id', getObjectifById);
  router.put('/api/objectifs/:id', updateObjectif);
  router.patch('/api/objectifs/:id/montant', addMontantObjectif);
  router.delete('/api/objectifs/:id', deleteObjectif);
};
