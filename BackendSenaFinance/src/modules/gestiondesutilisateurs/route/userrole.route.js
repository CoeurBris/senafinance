"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.userRolesRoutes = void 0;
const userRole_controller_1 = require("../controller/userRole.controller");
const userRolesRoutes = (router) => {
    // router.post('/api/roles/users/:id', checkPermission('AddUserRole'),createUserRole);
    // router.delete('/api/roles/users/:id',checkPermission('DeleteUserRole'),deleteUserRole);
    router.post('/api/roles/users/:id', userRole_controller_1.createUserRole);
    router.delete('/api/roles/users/:id', userRole_controller_1.deleteUserRole);
};
exports.userRolesRoutes = userRolesRoutes;
