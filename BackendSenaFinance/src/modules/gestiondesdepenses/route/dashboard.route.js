"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dashboardRoutes = void 0;
const dashboard_controller_1 = require("../controller/dashboard.controller");
const dashboardRoutes = (router) => {
    router.get('/api/dashboard', dashboard_controller_1.getDashboardData);
};
exports.dashboardRoutes = dashboardRoutes;
