import { Request, Response } from 'express';
import { ValidationError } from 'class-validator';
import { myDataSource } from '../../../configs/data-source';
import { generateServerErrorCode, success } from '../../../configs/response';
import { checkRelationsOneToMany } from '../../../configs/checkRelationsOneToManyBeforDelete';
import { paginationAndRechercheInit } from '../../../configs/paginationAndRechercheInit';
import { Category } from '../entity/category.entity';
import { Transaction } from '../entity/transaction.entity';

/**
 * Le TransactionModel Flutter envoie `category` comme un NOM de catégorie
 * (string), pas un `categoryId`. Cette fonction résout le nom en id avant
 * la création/mise à jour, tout en restant compatible si `categoryId` est
 * envoyé directement (ex: depuis un futur client web).
 *
 * ⚠️ Suppose que la colonne du nom dans `categories` s'appelle `name`.
 * Ajuste si besoin.
 */
const resolveCategoryId = async (
  body: Record<string, any>
): Promise<string | undefined> => {
  if (body.categoryId) return body.categoryId;
  if (!body.category) return undefined;

  const category = await myDataSource
    .getRepository(Category)
    .findOne({ where: { name: body.category } });

  return category?.id;
};

// ====================== CREATE ======================
export const createTransaction = async (req: Request, res: Response) => {
  try {
    const transactionRepository = myDataSource.getRepository(Transaction);

    const categoryId = await resolveCategoryId(req.body);

    const transaction = transactionRepository.create({
      ...(req.body as Partial<Transaction>),
      categoryId,
    });
    const savedTransaction = (await transactionRepository.save(
      transaction
    )) as Transaction;

    const message = `La transaction a bien été enregistrée.`;
    return success(res, 201, savedTransaction, message);
  } catch (error: any) {
    if (error instanceof ValidationError) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Les données de la transaction sont invalides.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "La transaction n'a pas pu être ajoutée. Réessayez dans quelques instants."
    );
  }
};

// ====================== GET ALL ======================
export const getAllTransactions = async (req: Request, res: Response) => {
  try {
    const transactions = await myDataSource.getRepository(Transaction).find({
      relations: ['category'],
      order: { date: 'DESC' }
    });

    const message = 'La liste des transactions a bien été récupérée.';
    return success(res, 200, transactions, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La liste des transactions n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== PAGINATED ======================
export const getTransactionsPaginated = async (req: Request, res: Response) => {
  try {
    const { limit, searchTerm, startIndex } = paginationAndRechercheInit(
      req,
      Transaction
    );

    let query = myDataSource
      .getRepository(Transaction)
      .createQueryBuilder('t')
      .leftJoinAndSelect('t.category', 'category');

    if (searchTerm) {
      query = query.where(
        '( t.title ILIKE :keyword OR t.note ILIKE :keyword OR category.name ILIKE :keyword )',
        { keyword: `%${searchTerm}%` }
      );
    }

    // Filtre optionnel par type: /transactions/paginated?type=Dépense
    if (req.query.type) {
      query = query.andWhere('t.type = :type', { type: req.query.type });
    }

    const [data, totalElements] = await query
      .orderBy('t.date', 'DESC')
      .skip(startIndex)
      .take(limit)
      .getManyAndCount();

    const totalPages = Math.ceil(totalElements / limit);
    const message = 'La liste des transactions a bien été récupérée.';

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
      'Erreur lors de la récupération des transactions.'
    );
  }
};

// ====================== GET BY ID ======================
export const getTransactionById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const transaction = await myDataSource.getRepository(Transaction).findOne({
      where: { id: id as any },
      relations: ['category']
    });

    if (!transaction) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "La transaction demandée n'existe pas."
      );
    }

    const message = 'La transaction a bien été trouvée.';
    return success(res, 200, transaction, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La transaction n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== UPDATE ======================
export const updateTransaction = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const transactionRepository = myDataSource.getRepository(Transaction);

    const transaction = await transactionRepository.findOne({
      where: { id: id as any }
    });

    if (!transaction) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Cette transaction n'existe pas."
      );
    }

    const categoryId = await resolveCategoryId(req.body);

    transactionRepository.merge(transaction, {
      ...req.body,
      ...(categoryId ? { categoryId } : {}),
    });
    const updatedTransaction = await transactionRepository.save(transaction);

    const message = `La transaction a bien été modifiée.`;
    return success(res, 200, updatedTransaction, message);
  } catch (error: any) {
    if (error instanceof ValidationError) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Les données sont invalides.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "La transaction n'a pas pu être modifiée. Réessayez dans quelques instants."
    );
  }
};

// ====================== DELETE ======================
export const deleteTransaction = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const transactionRepository = myDataSource.getRepository(Transaction);

    const transaction = await transactionRepository.findOne({
      where: { id: id as any }
    });

    if (!transaction) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "La transaction demandée n'existe pas."
      );
    }

    const hasRelations = await checkRelationsOneToMany('Transaction', id);
    if (hasRelations) {
      return generateServerErrorCode(
        res,
        400,
        'Relations existantes',
        "Cette transaction est liée à d'autres enregistrements et ne peut pas être supprimée."
      );
    }

    await transactionRepository.remove(transaction);

    const message = `La transaction a bien été supprimée.`;
    return success(res, 200, transaction, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La transaction n'a pas pu être supprimée. Réessayez dans quelques instants."
    );
  }
};