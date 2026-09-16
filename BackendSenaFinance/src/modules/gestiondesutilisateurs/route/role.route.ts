import * as express from 'express';
import { createRole, deleteRole,deleteRolePermission, getAllRoles, getRole, getSimpleRole, updateRole, createRolePermission, getRolesNotIn, getAllRole } from '../controller/role.controller';
import { checkPermission } from '../../../middlewares/auth.middleware';

export const rolesRoutes = (router: express.Router) => {
  // router.post('/api/roles',checkPermission('AddRole'), createRole);
  // router.get('/api/roles', checkPermission('ListeRole'),getAllRoles);
  // router.get('/api/roles/simple/:id', getSimpleRole);
  // router.get('/api/roles/:id', checkPermission ('ViewRole'),getRole);
  // router.delete('/api/roles/:id',  checkPermission('DeleteRole'),deleteRole);
  // router.delete('/api/rolePermission/:id',  checkPermission('DeleteRole'),deleteRolePermission);
  // router.put('/api/roles/:id', checkPermission('EditRole'),updateRole);
  // router.post('/api/roles/permissions',checkPermission('AddRole'), createRolePermeission);

  // router.post('/api/roles',checkPermission('AddRole'), createRole);
  // router.get('/api/roles',checkPermission('ListRole'),getAllRoles);
  // router.get('/api/rolesp',checkPermission('ListRoleP'),getAllRole);
  // router.get('/api/roles/simple/:id', checkPermission('ViewSimpeRole'),getSimpleRole);
  // router.get('/api/roles/:id',checkPermission('ViewRole'),getRole);
  // router.delete('/api/roles/:id',checkPermission('DeleteRole'),deleteRole);
  // router.delete('/api/rolePermission/:id',checkPermission('DeleteRolePermission'),deleteRolePermission);
  // router.get('/api/resteante/roles/:userId',checkPermission('RolesNotIn'), getRolesNotIn);
  // router.put('/api/roles/:id',checkPermission('EditRole'),updateRole);
  // router.post('/api/roles/permissions',checkPermission('AddRolePermission'), createRolePermission);


  router.post('/api/roles', createRole);
  router.get('/api/roles',getAllRoles);
  router.get('/api/rolesp',getAllRole);
  router.get('/api/roles/simple/:id', getSimpleRole);
  router.get('/api/roles/:id',getRole);
  router.delete('/api/roles/:id',deleteRole);
  router.delete('/api/rolePermission/:id',deleteRolePermission);
  router.get('/api/resteante/roles/:userId',getRolesNotIn);
  router.put('/api/roles/:id',updateRole);
  router.post('/api/roles/permissions',createRolePermission);

};