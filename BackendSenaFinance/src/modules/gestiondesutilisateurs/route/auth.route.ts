import * as express from 'express';
import {
    Register,
    Login,
    LoginMobile,
    ResetPasswordUser,
    SendResetPasswordCode,
    verifyAuth,
    Refresh,
    Logout,
} from '../controller/auth.controller';

export const authentication = (app: express.Router) => {
    app.post('/api/auth/register', Register);
    app.post('/api/auth/login', Login);
    app.post('/api/auth/login/mobile', LoginMobile);
    app.post('/api/auth/reset-password', ResetPasswordUser);
    app.post('/api/auth/send-reset-code', SendResetPasswordCode);
    app.post('/api/auth/verify', verifyAuth);
    app.post('/api/auth/refresh', Refresh);
    app.get('/api/auth/logout', Logout);
};