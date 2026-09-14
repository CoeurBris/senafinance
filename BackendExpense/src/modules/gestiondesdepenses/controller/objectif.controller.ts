import { Request, Response } from 'express';
import { myDataSource } from '../../../configs/data-source';
import { generateServerErrorCode, success } from '../../../configs/response';
import { paginationAndRechercheInit } from '../../../configs/paginationAndRechercheInit';
import { Objectif } from '../entity/objectif.entity';
import { Versement } from '../entity/versement.entity';

// ====================== CREATE ======================
export const createObjectif = async (req: Request, res: Response) => {
  try {
    const repo = myDataSource.getRepository(Objectif);

    // Adapte cette ligne à ton middleware d'auth :
    // si le userId vient du token JWT (ex: req.user.id), remplace la ligne
    // ci-dessous par : const userId = (req as any).user?.id;
    const userId = req.body.userId ?? (req as any).user?.id;

    const objectif = repo.create({
      ...(req.body as Partial<Objectif>),
      userId,
      currentAmount: req.body.currentAmount ?? 0,
    });

    const saved = await repo.save(objectif);

    return success(res, 201, saved, "L'objectif d'épargne a bien été créé.");
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "L'objectif n'a pas pu être créé. Réessayez dans quelques instants."
    );
  }
};

// ====================== GET ALL (de l'utilisateur connecté) ======================
export const getAllObjectifs = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id ?? req.query.userId;
    const where = userId ? { userId: userId as any } : {};

    const objectifs = await myDataSource.getRepository(Objectif).find({
      where,
      order: { id: 'DESC' as any },
    });

    return success(res, 200, objectifs, 'La liste des objectifs a bien été récupérée.');
  } catch (error: any) {
    console.error('❌ Erreur getAllObjectifs:', error);
    return generateServerErrorCode(
      res,
      500,
      error,
      "La liste des objectifs n'a pas pu être récupérée."
    );
  }
};

// ====================== PAGINATED ======================
export const getObjectifsPaginated = async (req: Request, res: Response) => {
  try {
    const { limit, searchTerm, startIndex } = paginationAndRechercheInit(
      req,
      Objectif
    );

    let query = myDataSource
      .getRepository(Objectif)
      .createQueryBuilder('o');

    if (searchTerm) {
      query = query.where('o.title ILIKE :keyword', { keyword: `%${searchTerm}%` });
    }

    const [data, totalElements] = await query
      .orderBy('o.id', 'DESC')
      .skip(startIndex)
      .take(limit)
      .getManyAndCount();

    const totalPages = Math.ceil(totalElements / limit);

    return success(
      res,
      200,
      { data, totalPages, totalElements, limit },
      'La liste des objectifs a bien été récupérée.'
    );
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      'Erreur lors de la récupération paginée des objectifs.'
    );
  }
};

// ====================== GET BY ID ======================
export const getObjectifById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const objectif = await myDataSource
      .getRepository(Objectif)
      .findOne({ where: { id: id as any } });

    if (!objectif) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "L'objectif demandé n'existe pas."
      );
    }

    return success(res, 200, objectif, "L'objectif a bien été trouvé.");
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "L'objectif n'a pas pu être récupéré."
    );
  }
};

// ====================== UPDATE (édition complète) ======================
export const updateObjectif = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const repo = myDataSource.getRepository(Objectif);

    const objectif = await repo.findOne({ where: { id: id as any } });

    if (!objectif) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Cet objectif n'existe pas."
      );
    }

    repo.merge(objectif, req.body);
    const updated = await repo.save(objectif);

    return success(res, 200, updated, "L'objectif a bien été modifié.");
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "L'objectif n'a pas pu être modifié."
    );
  }
};

// ====================== AJOUTER UN MONTANT (endpoint dédié) ======================
export const addMontantObjectif = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { amount } = req.body;

    if (amount === undefined || Number(amount) <= 0) {
      return generateServerErrorCode(
        res,
        400,
        'Montant invalide',
        'Le montant à ajouter doit être un nombre positif.'
      );
    }

    const objectifRepo = myDataSource.getRepository(Objectif);
    const versementRepo = myDataSource.getRepository(Versement);

    const objectif = await objectifRepo.findOne({ where: { id: id as any } });

    if (!objectif) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Cet objectif n'existe pas."
      );
    }

    objectif.currentAmount = Number(objectif.currentAmount) + Number(amount);

    // Transaction: on met à jour l'objectif ET on trace le versement ensemble
    const updated = await myDataSource.transaction(async (manager) => {
      const saved = await manager.save(Objectif, objectif);
      await manager.save(Versement, {
        objectifId: saved.id,
        montant: Number(amount),
      });
      return saved;
    });

    return success(res, 200, updated, 'Le montant a bien été ajouté à votre objectif.');
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "Le montant n'a pas pu être ajouté."
    );
  }
};

// ====================== HISTORIQUE DES VERSEMENTS ======================
export const getVersementsByObjectif = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const versements = await myDataSource.getRepository(Versement).find({
      where: { objectifId: id as any },
      order: { createdAt: 'ASC' as any },
    });

    return success(res, 200, versements, "L'historique a bien été récupéré.");
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "L'historique n'a pas pu être récupéré."
    );
  }
};


// // ====================== AJOUTER UN MONTANT (endpoint dédié) ======================
// export const addMontantObjectif = async (req: Request, res: Response) => {
//   try {
//     const { id } = req.params;
//     const { amount } = req.body;

//     if (amount === undefined || Number(amount) <= 0) {
//       return generateServerErrorCode(
//         res,
//         400,
//         'Montant invalide',
//         'Le montant à ajouter doit être un nombre positif.'
//       );
//     }

//     const repo = myDataSource.getRepository(Objectif);
//     const objectif = await repo.findOne({ where: { id: id as any } });

//     if (!objectif) {
//       return generateServerErrorCode(
//         res,
//         404,
//         "L'ID n'existe pas",
//         "Cet objectif n'existe pas."
//       );
//     }

//     objectif.currentAmount = Number(objectif.currentAmount) + Number(amount);
//     const updated = await repo.save(objectif);

//     return success(res, 200, updated, 'Le montant a bien été ajouté à votre objectif.');
//   } catch (error: any) {
//     return generateServerErrorCode(
//       res,
//       500,
//       error,
//       "Le montant n'a pas pu être ajouté."
//     );
//   }
// };

// ====================== DELETE ======================
export const deleteObjectif = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const repo = myDataSource.getRepository(Objectif);

    const objectif = await repo.findOne({ where: { id: id as any } });

    if (!objectif) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "L'objectif demandé n'existe pas."
      );
    }

    await repo.remove(objectif);

    return success(res, 200, objectif, "L'objectif a bien été supprimé.");
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "L'objectif n'a pas pu être supprimé."
    );
  }
};