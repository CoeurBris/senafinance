import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { myDataSource } from '../configs/data-source';
import { config } from '../configs/config';
import { generateServerErrorCode } from '../configs/response';
import { Permission } from '../modules/gestiondesutilisateurs/entity/permission.entity';

// Extension du type Request d'Express pour inclure les informations utilisateur
export interface CustomRequest extends Request {
  user?: any;
}

/**
 * Extraction et validation sécurisée du jeton Bearer
 */
const extractBearerToken = (req: Request): string | null => {
  const authHeader = req.headers.authorization || req.header('Authorization');
  if (!authHeader) return null;

  const parts = authHeader.split(' ');
  if (parts.length === 2 && parts[0] === 'Bearer') {
    return parts[1];
  }
  return null;
};

/**
 * Middleware d'authentification principal
 */
export const isAuthenticated = async (req: CustomRequest, res: Response, next: NextFunction) => {
  const token = extractBearerToken(req);

  if (!token) {
    return generateServerErrorCode(
      res,
      401,
      'token non renseigné',
      "Vous n'avez pas fourni de jeton d'authentification dans l'en-tête."
    );
  }

  jwt.verify(token, config.jwt.accessToken, (err, decodedToken: any) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return generateServerErrorCode(
          res,
          401,
          'token expiré',
          'Votre session a expiré, veuillez vous reconnecter.'
        );
      }
      return generateServerErrorCode(
        res,
        403,
        "Le jeton n'est pas valide",
        "Échec d'authentification."
      );
    }

    req.user = {
      id: decodedToken.userId,
      ...decodedToken
    };

    next();
  });
};

/**
 * Middleware d'authentification étendu (Gestion du point de vente)
 */
export const isAuthenticatedOne = async (req: CustomRequest, res: Response, next: NextFunction) => {
  const token = extractBearerToken(req);

  if (!token) {
    return generateServerErrorCode(
      res,
      401,
      'token non renseigné',
      "Vous n'avez pas fourni de jeton d'authentification."
    );
  }

  jwt.verify(token, config.jwt.accessToken, (err, decodedToken: any) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return generateServerErrorCode(
          res,
          401,
          'token expiré',
          'Votre session a expiré, veuillez vous reconnecter.'
        );
      }
      return generateServerErrorCode(
        res,
        401,
        'token invalide',
        "L'utilisateur n'est pas autorisé à accéder à cette ressource."
      );
    }

    const userId = decodedToken.userId;
    req.user = { id: userId, ...decodedToken };

    if (req.body) {
      req.body.userCreation = userId;
    }

    // Gestion du point de vente par défaut et de ses permissions
    const pointventesArray: string[] = decodedToken.pointventes
      ? decodedToken.pointventes.split(',')
      : [];
    const pointventeParDefaut = decodedToken?.pointvente || '';

    if (req.method === 'GET') {
      if (!req.query.pointvente || req.query.pointvente === '') {
        req.query.pointvente = pointventeParDefaut;
      }
    } else {
      if (!req.body.pointvente || req.body.pointvente === '') {
        req.body.pointvente = pointventeParDefaut;
      }
    }

    const currentPv = req.method === 'GET' ? req.query.pointvente : req.body.pointvente;

    if (pointventesArray.length > 0 && currentPv) {
      if (!pointventesArray.includes(currentPv.toString())) {
        return generateServerErrorCode(
          res,
          403,
          'Accès refusé',
          "L'utilisateur n'est pas autorisé à accéder à ce point de vente."
        );
      }
    }

    next();
  });
};

/**
 * Middleware de vérification des privilèges
 */
export const checkPermission = (resource: string) => {
  return async (req: CustomRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id || req.user;

      if (!userId) {
        return generateServerErrorCode(
          res,
          401,
          "Non authentifié",
          "Vous devez être connecté pour accéder à cette fonctionnalité."
        );
      }

      const permissions = await myDataSource
        .getRepository(Permission)
        .createQueryBuilder('permission')
        .leftJoin('permission.rolePermissions', 'rolePermission')
        .leftJoin('rolePermission.role', 'role')
        .leftJoin('role.userRoles', 'userRoles')
        .leftJoin('userRoles.user', 'user')
        .where('user.id = :ident', { ident: userId })
        .andWhere('permission.nom = :resou', { resou: resource })
        .getMany();

      if (permissions.length > 0) {
        return next();
      }

      return generateServerErrorCode(
        res,
        403,
        "Privilège insuffisant",
        "Vous n'avez pas les droits nécessaires pour effectuer cette action."
      );
    } catch (error) {
      console.error('[checkPermission] Erreur SQL / Serveur:', error);
      return generateServerErrorCode(
        res,
        500,
        "Erreur serveur",
        "Erreur lors de la vérification des droits d'accès."
      );
    }
  };
};