import multer from 'multer';
import path from 'path';
import fs from 'fs';

/**
 * ============================================================
 * CHEMIN DE BASE DES UPLOADS
 * ============================================================
 *
 * En production (Render), UPLOADS_PATH pointe vers le disque
 * persistant monté. En local, on retombe sur le dossier
 * "uploads" relatif au projet.
 */

const UPLOADS_BASE_PATH =
  process.env.UPLOADS_PATH ||
  path.join(__dirname, '../../uploads');

/**
 * ============================================================
 * TYPES MIME
 * ============================================================
 */

const MIME_TYPES: { [key: string]: string } = {
  'image/jpg': 'jpg',
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',

  'application/pdf': 'pdf',

  'application/msword': 'doc',

  'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
    'docx',
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

const storage = multer.diskStorage({
  destination: (req, file, callback) => {
    const subFolder =
      req.body.dossier || 'Autres';

    const finalPath = path.join(
      UPLOADS_BASE_PATH,
      subFolder
    );

    if (!fs.existsSync(finalPath)) {
      fs.mkdirSync(finalPath, {
        recursive: true,
      });
    }

    callback(null, finalPath);
  },

  filename: (req, file, callback) => {
    const extension =
      MIME_TYPES[file.mimetype] || 'bin';

    const timestamp = Date.now();

    const randomString = Math.random()
      .toString(36)
      .substring(7);

    const filename =
      `${timestamp}${randomString}.${extension}`;

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

const AVATAR_UPLOAD_PATH = path.join(
  UPLOADS_BASE_PATH,
  'avatars'
);

if (!fs.existsSync(AVATAR_UPLOAD_PATH)) {
  fs.mkdirSync(AVATAR_UPLOAD_PATH, {
    recursive: true,
  });

  console.log(
    'Dossier uploads/avatars créé :',
    AVATAR_UPLOAD_PATH
  );
}

const avatarStorage = multer.diskStorage({
  destination: (_req, _file, callback) => {
    callback(
      null,
      AVATAR_UPLOAD_PATH
    );
  },

  filename: (_req, file, callback) => {
    const extension =
      MIME_TYPES[file.mimetype] || 'jpg';

    const timestamp = Date.now();

    const randomString = Math.random()
      .toString(36)
      .substring(7);

    const filename =
      `avatar-${timestamp}-${randomString}.${extension}`;

    callback(null, filename);
  },
});

/**
 * ============================================================
 * STORAGE FINANCES
 * ============================================================
 */

const FINANCE_UPLOAD_PATH = path.join(
  UPLOADS_BASE_PATH,
  'Finances'
);

if (!fs.existsSync(FINANCE_UPLOAD_PATH)) {
  fs.mkdirSync(FINANCE_UPLOAD_PATH, {
    recursive: true,
  });

  console.log(
    'Dossier uploads/Finances créé :',
    FINANCE_UPLOAD_PATH
  );
}

const financeStorage = multer.diskStorage({
  destination: (_req, _file, callback) => {
    callback(
      null,
      FINANCE_UPLOAD_PATH
    );
  },

  filename: (_req, file, callback) => {
    const extension =
      MIME_TYPES[file.mimetype] || 'bin';

    const timestamp = Date.now();

    const randomString = Math.random()
      .toString(36)
      .substring(7);

    const filename =
      `${timestamp}_${randomString}.${extension}`;

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

export const upload = multer({
  storage,
});

/**
 * Alias conservé pour les anciens fichiers.
 */

export const uploads = multer({
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

export const avatarUpload = multer({
  storage: avatarStorage,
});

/**
 * ============================================================
 * MULTER FINANCES
 * ============================================================
 */

export const financeListen = multer({
  storage: financeStorage,
});