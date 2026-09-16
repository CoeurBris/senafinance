"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.userPointventesRoutes = void 0;
const userPointVente_controller_1 = require("../controller/userPointVente.controller");
const auth_middleware_1 = require("../../../middlewares/auth.middleware");
const userPointventesRoutes = (router) => {
    router.post('/api/pointventes/users/:id', (0, auth_middleware_1.checkPermission)('AddUserPointvente'), userPointVente_controller_1.createUserPointVente);
    router.delete('/api/pointventes/users/:id', (0, auth_middleware_1.checkPermission)('DeleteUserPointvente'), userPointVente_controller_1.deleteUserPointVente);
};
exports.userPointventesRoutes = userPointventesRoutes;
