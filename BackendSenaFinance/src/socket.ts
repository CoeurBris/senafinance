// src/socket.ts
import { Server as SocketIOServer } from "socket.io";
import { Server as HttpServer } from "http";

let io: SocketIOServer;

export const initSocketIO = (server: HttpServer) => {
  io = new SocketIOServer(server, {
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

export const getIO = (): SocketIOServer => {
  if (!io) {
    throw new Error("Socket.IO non initialisé !");
  }
  return io;
};
