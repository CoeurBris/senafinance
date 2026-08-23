  import { Request, Response } from "express";
  import { User } from '../entity/user.entity';
  import * as bcryptjs from 'bcryptjs';
  import { myDataSource } from '../../../configs/data-source';
  import { generateServerErrorCode, success, validateMessage } from '../../../configs/response';
  import { ValidationError, validate } from 'class-validator';
  import { paginationAndRechercheInit } from "../../../configs/paginationAndRechercheInit";
  import { Brackets } from "typeorm";
  import { UserRole } from "../entity/UserRole.entity";

  export const createUser = async (req: Request, res: Response) => {
    try {
      const { password, roles, ...userDataBody } = req.body;

      if (userDataBody.telephone) {
        userDataBody.telephone = userDataBody.telephone.replace(/\s/g, '');
      }

      // Hachage du mot de passe s'il est fourni dans la requête
      const hashedPassword = password ? await bcryptjs.hash(password, 12) : undefined;

      const userRepository = myDataSource.getRepository(User);
      const userData = userRepository.create({
        ...userDataBody,
        ...(hashedPassword && { password: hashedPassword })
      });

      const errors = await validate(userData);
      if (errors.length > 0) {
        return generateServerErrorCode(res, 400, errors, validateMessage(errors));
      }

      await myDataSource.manager.transaction(async (transactionalEntityManager) => {
        const userSaved = await transactionalEntityManager.getRepository(User).save(userData);

        // Extraction explicite de l'objet utilisateur (même si un tableau est retourné)
        const user: User = Array.isArray(userSaved) ? userSaved[0] : userSaved;

        if (roles) {
          const userRole = new UserRole();
          userRole.userId = user.id;
          userRole.roleId = roles;
          userRole.dateAffectation = new Date();
          await transactionalEntityManager.getRepository(UserRole).save(userRole);
        }

        // Extraction de password depuis l'instance 'user' (et non 'userData' ou 'userSaved')
        const { password: pwd, ...userWithoutPassword } = user;
        return success(res, 201, userWithoutPassword, `L'utilisateur a bien été créé.`);
      });

    } catch (error: any) {
      const message = error.code === "ER_DUP_ENTRY" || error.code === "23505"
        ? "Cet utilisateur existe déjà (email ou numéro de téléphone en doublon)."
        : "L'utilisateur n'a pas pu être ajouté.";

      return generateServerErrorCode(res, 500, error, message);
    }
  };


  export const getAllUsers = async (req: Request, res: Response) => {
    const { limit, searchTerm, startIndex, searchQueries } = paginationAndRechercheInit(req, User);

    try {
      const [data, totalElements] = await myDataSource.getRepository(User)
        .createQueryBuilder('user')
        .where("user.deletedAt IS NULL")
        .andWhere(searchQueries.length > 0 ? new Brackets(qb => {
          qb.where(searchQueries.join(' OR '), { keyword: `%${searchTerm}%` })
        }) : '1=1')
        .orderBy('user.createdAt', 'DESC')
        .skip(startIndex)
        .take(limit)
        .getManyAndCount();

      const sanitizedData = data.map(({ password, ...user }) => user);
      const totalPages = Math.ceil(totalElements / limit) || 1;

      return success(res, 200, { data: sanitizedData, totalPages, totalElements, limit }, 'La liste des utilisateurs a bien été récupérée.');
    } catch (error: any) {
      return generateServerErrorCode(res, 500, error, `La liste des utilisateurs n'a pas pu être récupérée.`);
    }
  };

  export const getAllAllUsers = async (req: Request, res: Response) => {
    try {
      const data = await myDataSource.getRepository(User)
        .createQueryBuilder('user')
        .where("user.deletedAt IS NULL")
        .orderBy('user.createdAt', 'DESC')
        .getMany();

      const sanitizedData = data.map(({ password, ...user }) => user);
      return success(res, 200, sanitizedData, 'La liste de tous les utilisateurs a bien été récupérée.');
    } catch (error: any) {
      return generateServerErrorCode(res, 500, error, `La liste des utilisateurs n'a pas pu être récupérée.`);
    }
  };

  export const getUser = async (req: Request, res: Response) => {
    try {
      const userId = parseInt(req.params.id, 10);

      if (isNaN(userId)) {
        return generateServerErrorCode(res, 400, "ID invalide", "L'identifiant fourni est invalide.");
      }

      const user = await myDataSource.getRepository(User).findOne({
        where: { id: userId }
      });

      if (!user) {
        return generateServerErrorCode(res, 404, "L'id n'existe pas", `L'utilisateur demandé n'existe pas.`);
      }

      const { password, ...userWithoutPassword } = user;
      return success(res, 200, userWithoutPassword, "L'utilisateur a bien été trouvé.");
    } catch (error: any) {
      return generateServerErrorCode(res, 500, error, `L'utilisateur n'a pas pu être récupéré.`);
    }
  };

  export const updateUser = async (req: Request, res: Response) => {
    try {
      const userId = parseInt(req.params.id, 10);

      if (isNaN(userId)) {
        return generateServerErrorCode(res, 400, "ID invalide", "L'identifiant fourni est invalide.");
      }

      const userRepository = myDataSource.getRepository(User);
      let user = await userRepository.findOne({ where: { id: userId } });

      if (!user) {
        return generateServerErrorCode(res, 404, "L'id n'existe pas", "L'utilisateur demandé n'existe pas.");
      }

      const { password, ...updateData } = req.body;
      userRepository.merge(user, updateData);

      const errors = await validate(user);
      if (errors.length > 0) {
        return generateServerErrorCode(res, 400, errors, validateMessage(errors));
      }

      const updatedUser = await userRepository.save(user);
      const { password: pwd, ...userWithoutPassword } = updatedUser;

      return success(res, 200, userWithoutPassword, `L'utilisateur ${updatedUser.nom || ''} a bien été modifié.`);

    } catch (error: any) {
      if (error instanceof ValidationError) {
        return generateServerErrorCode(res, 400, error, 'Erreur de validation.');
      }
      if (error.code === "ER_DUP_ENTRY" || error.code === "23505") {
        return generateServerErrorCode(res, 400, error, 'Cet utilisateur existe déjà.');
      }
      return generateServerErrorCode(res, 500, error, `L'utilisateur n'a pas pu être modifié.`);
    }
  };

  export const updatePassword = async (req: Request, res: Response) => {
    try {
      const userId = parseInt(req.params.id, 10);
      const { password, newPassword } = req.body;

      if (!password || !newPassword) {
        return generateServerErrorCode(res, 400, '', "L'ancien et le nouveau mot de passe sont requis.");
      }

      const userRepository = myDataSource.getRepository(User);
      const utilisateur = await userRepository.findOne({ where: { id: userId } });

      if (!utilisateur) {
        return generateServerErrorCode(res, 404, "L'id n'existe pas", "L'utilisateur demandé n'existe pas.");
      }

      if (!utilisateur.password) {
        return generateServerErrorCode(res, 400, 'Invalid Credentials', "Aucun mot de passe n'est configuré pour ce compte.");
      }

      const isMatch = await bcryptjs.compare(password, utilisateur.password);
      if (!isMatch) {
        return generateServerErrorCode(res, 400, 'Invalid Credentials', "L'ancien mot de passe est incorrect.");
      }

      const hashedNewPassword = await bcryptjs.hash(newPassword, 12);
      await userRepository.update(userId, { password: hashedNewPassword });

      return success(res, 200, null, `La modification du mot de passe s'est bien passée.`);

    } catch (error: any) {
      return generateServerErrorCode(res, 500, error, `Le mot de passe n'a pas pu être modifié.`);
    }
  };

  export const ChangerPasswordAdmin = async (req: Request, res: Response) => {
    try {
      const userId = parseInt(req.params.id, 10);
      const { newPassword } = req.body;

      if (!newPassword) {
        return generateServerErrorCode(res, 400, '', "Le nouveau mot de passe est requis.");
      }

      const userRepository = myDataSource.getRepository(User);
      const user = await userRepository.findOne({ where: { id: userId } });

      if (!user) {
        return generateServerErrorCode(res, 404, "L'id n'existe pas", "L'utilisateur demandé n'existe pas.");
      }

      const hashedNewPassword = await bcryptjs.hash(newPassword, 12);
      await userRepository.update(userId, { password: hashedNewPassword });

      return success(res, 200, null, `La réinitialisation du mot de passe par l'administrateur s'est bien passée.`);

    } catch (error: any) {
      return generateServerErrorCode(res, 500, error, `Le mot de passe n'a pas pu être modifié.`);
    }
  };

  export const deleteUser = async (req: Request, res: Response) => {
    try {
      const userId = parseInt(req.params.id, 10);

      if (isNaN(userId)) {
        return generateServerErrorCode(res, 400, "ID invalide", "L'identifiant fourni est invalide.");
      }

      const userRepository = myDataSource.getRepository(User);
      const user = await userRepository.findOneBy({ id: userId });

      if (!user) {
        return generateServerErrorCode(res, 404, "L'id n'existe pas", `L'utilisateur demandé n'existe pas.`);
      }

      await userRepository.softRemove(user);
      const { password, ...userWithoutPassword } = user;

      return success(res, 200, userWithoutPassword, `L'utilisateur n°${user.id} a bien été supprimé.`);

    } catch (error: any) {
      return generateServerErrorCode(res, 500, error, `L'utilisateur n'a pas pu être supprimé.`);
    }
  };

export const updatePhoto = async (
  req: Request,
  res: Response
) => {
  try {
    if (!req.user) {
      return generateServerErrorCode(
        res,
        401,
        'Utilisateur non authentifié',
        'Vous devez être connecté pour modifier votre photo de profil.'
      );
    }

    if (!req.file) {
      return generateServerErrorCode(
        res,
        400,
        'Aucune image',
        'Veuillez sélectionner une image.'
      );
    }

    const userRepository =
      myDataSource.getRepository(User);

    const user = await userRepository.findOne({
      where: {
        id: req.user.id,
      },
    });

    if (!user) {
      return generateServerErrorCode(
        res,
        404,
        'Utilisateur introuvable',
        "L'utilisateur connecté n'existe pas."
      );
    }

    // URL enregistrée en base
    user.photoUrl =
      `/uploads/avatars/${req.file.filename}`;

    const updatedUser =
      await userRepository.save(user);

    const {
      password,
      ...userWithoutPassword
    } = updatedUser;

    return success(
      res,
      200,
      userWithoutPassword,
      'La photo de profil a bien été mise à jour.'
    );

  } catch (error: any) {

    console.error(
      'Erreur updatePhoto:',
      error
    );

    return generateServerErrorCode(
      res,
      500,
      error,
      "La photo de profil n'a pas pu être mise à jour."
    );
  }
};