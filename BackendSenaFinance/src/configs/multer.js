"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.financeListen = exports.avatarUpload = exports.uploads = exports.upload = void 0;
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
/**
 * ============================================================
 * TYPES MIME
 * ============================================================
 */
const MIME_TYPES = {
    'image/jpg': 'jpg',
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
    'application/pdf': 'pdf',
    'application/msword': 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
};
/**
 * ============================================================
 * STORAGE GENERAL
 * ============================================================
 *
 * Les fichiers sont enregistrés dans :
 *
 * uploads/
 * ├── Autres/
 * ├── Finances/
 * └── ...
 *
 * Le sous-dossier peut être envoyé via :
 *
 * req.body.dossier
 */
const storage = multer_1.default.diskStorage({
    destination: (req, file, callback) => {
        const uploadBasePath = path_1.default.join(__dirname, '../../uploads');
        const subFolder = req.body.dossier || 'Autres';
        const finalPath = path_1.default.join(uploadBasePath, subFolder);
        if (!fs_1.default.existsSync(finalPath)) {
            fs_1.default.mkdirSync(finalPath, {
                recursive: true,
            });
        }
        callback(null, finalPath);
    },
    filename: (req, file, callback) => {
        const extension = MIME_TYPES[file.mimetype] || 'bin';
        const timestamp = Date.now();
        const randomString = Math.random()
            .toString(36)
            .substring(7);
        const filename = `${timestamp}${randomString}.${extension}`;
        callback(null, filename);
    },
});
/**
 * ============================================================
 * STORAGE AVATARS
 * ============================================================
 *
 * Les photos de profil sont enregistrées dans :
 *
 * uploads/
 * └── avatars/
 *     ├── avatar-xxx.jpg
 *     ├── avatar-yyy.png
 *     └── ...
 */
const AVATAR_UPLOAD_PATH = path_1.default.join(__dirname, '../../uploads/avatars');
if (!fs_1.default.existsSync(AVATAR_UPLOAD_PATH)) {
    fs_1.default.mkdirSync(AVATAR_UPLOAD_PATH, {
        recursive: true,
    });
    console.log('Dossier uploads/avatars créé :', AVATAR_UPLOAD_PATH);
}
const avatarStorage = multer_1.default.diskStorage({
    destination: (_req, _file, callback) => {
        callback(null, AVATAR_UPLOAD_PATH);
    },
    filename: (_req, file, callback) => {
        const extension = MIME_TYPES[file.mimetype] || 'jpg';
        const timestamp = Date.now();
        const randomString = Math.random()
            .toString(36)
            .substring(7);
        const filename = `avatar-${timestamp}-${randomString}.${extension}`;
        callback(null, filename);
    },
});
/**
 * ============================================================
 * STORAGE FINANCES
 * ============================================================
 */
const FINANCE_UPLOAD_PATH = path_1.default.join(__dirname, '../../uploads/Finances');
if (!fs_1.default.existsSync(FINANCE_UPLOAD_PATH)) {
    fs_1.default.mkdirSync(FINANCE_UPLOAD_PATH, {
        recursive: true,
    });
    console.log('Dossier uploads/Finances créé :', FINANCE_UPLOAD_PATH);
}
const financeStorage = multer_1.default.diskStorage({
    destination: (_req, _file, callback) => {
        callback(null, FINANCE_UPLOAD_PATH);
    },
    filename: (_req, file, callback) => {
        const extension = MIME_TYPES[file.mimetype] || 'bin';
        const timestamp = Date.now();
        const randomString = Math.random()
            .toString(36)
            .substring(7);
        const filename = `${timestamp}_${randomString}.${extension}`;
        callback(null, filename);
    },
});
/**
 * ============================================================
 * MULTER GENERAL
 * ============================================================
 *
 * Utilisation :
 *
 * upload.single('photo')
 * upload.single('fichier')
 * upload.array('fichiers')
 */
exports.upload = (0, multer_1.default)({
    storage,
});
/**
 * Alias conservé pour les anciens fichiers.
 */
exports.uploads = (0, multer_1.default)({
    storage,
});
/**
 * ============================================================
 * MULTER AVATAR
 * ============================================================
 *
 * Utilisation :
 *
 * avatarUpload.single('photo')
 */
exports.avatarUpload = (0, multer_1.default)({
    storage: avatarStorage,
});
/**
 * ============================================================
 * MULTER FINANCES
 * ============================================================
 */
exports.financeListen = (0, multer_1.default)({
    storage: financeStorage,
});
