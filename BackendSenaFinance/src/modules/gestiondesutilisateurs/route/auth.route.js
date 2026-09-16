"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authentication = void 0;
const auth_controller_1 = require("../controller/auth.controller");
const authentication = (app) => {
    app.post('/api/auth/register', auth_controller_1.Register);
    app.post('/api/auth/login', auth_controller_1.Login);
    app.post('/api/auth/login/mobile', auth_controller_1.LoginMobile);
    app.post('/api/auth/reset-password', auth_controller_1.ResetPasswordUser);
    app.post('/api/auth/send-reset-code', auth_controller_1.SendResetPasswordCode);
    app.post('/api/auth/verify', auth_controller_1.verifyAuth);
    app.post('/api/auth/refresh', auth_controller_1.Refresh);
    app.get('/api/auth/logout', auth_controller_1.Logout);
};
exports.authentication = authentication;
