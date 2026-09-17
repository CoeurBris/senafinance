"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateMessage = exports.success = exports.generateServerErrorCode = void 0;
const generateServerErrorCode = (res, code, errors, message) => {
    return res.status(code).json({ code, message, errors });
};
exports.generateServerErrorCode = generateServerErrorCode;
const success = (res, code, data, message) => {
    return res.status(code).json({ code, message, data });
};
exports.success = success;
const validateMessage = (errors) => {
    var message = '';
    errors.forEach(element => {
        message = message + element.constraints.isNotEmpty + ' ';
    });
    return message;
};
exports.validateMessage = validateMessage;
