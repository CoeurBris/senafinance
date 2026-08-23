"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const uploadDir = path_1.default.join(__dirname, "..", "uploads", "avatars");
// Créer le dossier s'il n'existe pas
if (!fs_1.default.existsSync(uploadDir)) {
    fs_1.default.mkdirSync(uploadDir, { recursive: true });
}
const storage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        var _a;
        // ID de l'utilisateur connecté
        const userId = ((_a = req.user) === null || _a === void 0 ? void 0 : _a.id) || "anonyme";
        // Extension du fichier
        const ext = path_1.default.extname(file.originalname).toLowerCase();
        // Nom unique
        cb(null, `${userId}_${Date.now()}${ext}`);
    },
});
const fileFilter = (req, file, cb) => {
    const allowed = [".jpg", ".jpeg", ".png", ".webp"];
    const ext = path_1.default.extname(file.originalname).toLowerCase();
    if (allowed.includes(ext)) {
        cb(null, true);
    }
    else {
        cb(new Error("Format d'image non supporté (jpg, jpeg, png, webp uniquement)"));
    }
};
const upload = (0, multer_1.default)({
    storage,
    fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5 Mo maximum
    },
});
exports.default = upload;
