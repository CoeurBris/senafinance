import multer, { FileFilterCallback } from "multer";
import path from "path";
import fs from "fs";
import { Request } from "express";
import { Readable } from "stream";

const uploadDir = path.join(__dirname, "..", "uploads", "avatars");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Type indépendant de l'augmentation globale Express.Multer.File
// (celle-ci ne se charge pas de façon fiable sur certains environnements de build)
export interface MulterFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  // stream: NodeJS.ReadableStream;
    stream: Readable;
  destination: string;
  filename: string;
  path: string;
  buffer: Buffer;
}
// export interface MulterFile {
//   fieldname: string;
//   originalname: string;
//   encoding: string;
//   mimetype: string;
//   size: number;
//   destination: string;
//   filename: string;
//   path: string;
//   buffer: Buffer;
// }

const storage = multer.diskStorage({
  destination: (
    req: Request,
    file: MulterFile,
    cb: (error: Error | null, destination: string) => void
  ) => {
    cb(null, uploadDir);
  },

  filename: (
    req: Request,
    file: MulterFile,
    cb: (error: Error | null, filename: string) => void
  ) => {
    const userId = req.user?.id || "anonyme";
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${userId}_${Date.now()}${ext}`);
  },
});

const fileFilter = (
  req: Request,
  file: MulterFile,
  cb: FileFilterCallback
) => {
  const allowed = [".jpg", ".jpeg", ".png", ".webp"];
  const ext = path.extname(file.originalname).toLowerCase();

  if (allowed.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error("Format d'image non supporté (jpg, jpeg, png, webp uniquement)"));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

export default upload;