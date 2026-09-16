"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIO = exports.initSocketIO = void 0;
// src/socket.ts
const socket_io_1 = require("socket.io");
let io;
const initSocketIO = (server) => {
    io = new socket_io_1.Server(server, {
        cors: {
            origin: "*",
            methods: ["GET", "POST"]
        }
    });
    io.on("connection", (socket) => {
        console.log(" Client connecté :", socket.id);
        socket.on("disconnect", () => {
            console.log(" Client déconnecté :", socket.id);
        });
        socket.on("message", (data) => {
            console.log("📨 Message reçu :", data);
            io.emit("message", data);
        });
    });
};
exports.initSocketIO = initSocketIO;
const getIO = () => {
    if (!io) {
        throw new Error("Socket.IO non initialisé !");
    }
    return io;
};
exports.getIO = getIO;
