import * as express from 'express';
import { createUserRole, deleteUserRole } from '../controller/userRole.controller';
import { checkPermission } from '../../../middlewares/auth.middleware';

export const userRolesRoutes = (router: express.Router) => {
    
    // router.post('/api/roles/users/:id', checkPermission('AddUserRole'),createUserRole);
    // router.delete('/api/roles/users/:id',checkPermission('DeleteUserRole'),deleteUserRole);
      
 router.post('/api/roles/users/:id', createUserRole);
    router.delete('/api/roles/users/:id',deleteUserRole);

    };