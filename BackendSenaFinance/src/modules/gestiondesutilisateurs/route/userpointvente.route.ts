import * as express from 'express';
import { createUserPointVente, deleteUserPointVente } from '../controller/userPointVente.controller';
import { checkPermission } from '../../../middlewares/auth.middleware';

export const userPointventesRoutes = (router: express.Router) => {
    
    router.post('/api/pointventes/users/:id', checkPermission('AddUserPointvente'),createUserPointVente);
    router.delete('/api/pointventes/users/:id',checkPermission('DeleteUserPointvente'),deleteUserPointVente);
      
    };