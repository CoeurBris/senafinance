import { Request, Response } from 'express';
import { ValidationError } from 'class-validator';
import { myDataSource } from '../../../configs/data-source';
import { generateServerErrorCode, success } from '../../../configs/response';
import { checkRelationsOneToMany } from '../../../configs/checkRelationsOneToManyBeforDelete';
import { paginationAndRechercheInit } from '../../../configs/paginationAndRechercheInit';
import { Budget } from '../entity/budget.entity';

// ====================== CREATE ======================
export const createBudget = async (req: Request, res: Response) => {
  try {
    const budgetRepository = myDataSource.getRepository(Budget);
    const budget = budgetRepository.create(req.body as Partial<Budget>);
    const savedBudget = (await budgetRepository.save(budget)) as Budget;

    const message = `Le budget a bien été créé.`;
    return success(res, 201, savedBudget, message);
  } catch (error: any) {
    if (error instanceof ValidationError) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Les données du budget sont invalides.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "Le budget n'a pas pu être ajouté. Réessayez dans quelques instants."
    );
  }
};

// ====================== GET ALL ======================
export const getAllBudgets = async (req: Request, res: Response) => {
  try {
    const budgets = await myDataSource.getRepository(Budget).find({
      relations: ['category'],
      order: { id: 'DESC' as any },
    });

    const message = 'La liste des budgets a bien été récupérée.';
    return success(res, 200, budgets, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La liste des budgets n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== PAGINATED ======================
export const getBudgetsPaginated = async (req: Request, res: Response) => {
  try {
    const { limit, searchTerm, startIndex } = paginationAndRechercheInit(
      req,
      Budget
    );

    let query = myDataSource
      .getRepository(Budget)
      .createQueryBuilder('b')
      .leftJoinAndSelect('b.category', 'category');

    if (searchTerm) {
      query = query.where(
        '( category.name ILIKE :keyword OR b.description ILIKE :keyword )',
        { keyword: `%${searchTerm}%` }
      );
    }

    const [data, totalElements] = await query
      .orderBy('b.id', 'DESC')
      .skip(startIndex)
      .take(limit)
      .getManyAndCount();

    const totalPages = Math.ceil(totalElements / limit);
    const message = 'La liste des budgets a bien été récupérée.';

    return success(
      res,
      200,
      { data, totalPages, totalElements, limit },
      message
    );
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "Erreur lors de la récupération paginée des budgets."
    );
  }
};

// ====================== GET BY ID ======================
export const getBudgetById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const budget = await myDataSource.getRepository(Budget).findOne({
      where: { id: id as any },
      relations: ['category'],
    });

    if (!budget) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Le budget demandé n'existe pas."
      );
    }

    const message = 'Le budget a bien été trouvé.';
    return success(res, 200, budget, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "Le budget n'a pas pu être récupéré. Réessayez dans quelques instants."
    );
  }
};

// ====================== UPDATE ======================
export const updateBudget = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const budgetRepository = myDataSource.getRepository(Budget);

    const budget = await budgetRepository.findOne({
      where: { id: id as any },
    });

    if (!budget) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Ce budget n'existe pas."
      );
    }

    budgetRepository.merge(budget, req.body);
    const updatedBudget = await budgetRepository.save(budget);

    const message = `Le budget a bien été modifié.`;
    return success(res, 200, updatedBudget, message);
  } catch (error: any) {
    if (error instanceof ValidationError) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Les données du budget sont invalides.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "Le budget n'a pas pu être modifié. Réessayez dans quelques instants."
    );
  }
};

// ====================== DELETE ======================
export const deleteBudget = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const budgetRepository = myDataSource.getRepository(Budget);

    const budget = await budgetRepository.findOne({
      where: { id: id as any },
    });

    if (!budget) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Le budget demandé n'existe pas."
      );
    }

    const hasRelations = await checkRelationsOneToMany('Budget', id);
    if (hasRelations) {
      return generateServerErrorCode(
        res,
        400,
        'Relations existantes',
        'Ce budget est lié à d\'autres enregistrements et ne peut pas être supprimé.'
      );
    }

    await budgetRepository.remove(budget);

    const message = `Le budget a bien été supprimé.`;
    return success(res, 200, budget, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "Le budget n'a pas pu être supprimé. Réessayez dans quelques instants."
    );
  }
};