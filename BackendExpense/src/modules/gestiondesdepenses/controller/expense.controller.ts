import { Request, Response } from 'express';
import { ValidationError } from 'class-validator';
import { myDataSource } from '../../../configs/data-source';
import { generateServerErrorCode, success } from '../../../configs/response';
import { checkRelationsOneToMany } from '../../../configs/checkRelationsOneToManyBeforDelete';
import { paginationAndRechercheInit } from '../../../configs/paginationAndRechercheInit';
import { Expense } from '../entity/expense.entity';
import { Budget } from '../entity/budget.entity';
import { Notification } from '../entity/notification.entity';

// ====================== CREATE ======================
export const createExpense = async (req: Request, res: Response) => {
  try {
    const expenseRepository = myDataSource.getRepository(Expense);
    const notificationRepo = myDataSource.getRepository(Notification);
    const expense = expenseRepository.create(req.body as Partial<Expense>);
    const savedExpense = (await expenseRepository.save(expense)) as Expense;

    // Pas de budgetId direct : on retrouve le budget actif via
    // categoryId + userId (+ période startDate/endDate si définie).
    if (savedExpense.categoryId && savedExpense.userId) {
      const budgetRepo = myDataSource.getRepository(Budget);

      let budgetQuery = budgetRepo
        .createQueryBuilder('b')
        .where('b.categoryId = :categoryId', { categoryId: savedExpense.categoryId })
        .andWhere('b.userId = :userId', { userId: Number(savedExpense.userId) });

      if (savedExpense.date) {
        budgetQuery = budgetQuery
          .andWhere('(b.startDate IS NULL OR b.startDate <= :date)', { date: savedExpense.date })
          .andWhere('(b.endDate IS NULL OR b.endDate >= :date)', { date: savedExpense.date });
      }

      const budget = await budgetQuery.getOne();

      if (budget && budget.amountLimit > 0) {
        const totalSpent = await myDataSource
          .getRepository(Expense)
          .createQueryBuilder('e')
          .where('e.categoryId = :categoryId', { categoryId: budget.categoryId })
          .andWhere('e.userId = :userId', { userId: savedExpense.userId })
          .select('SUM(e.amount)', 'total')
          .getRawOne();

        const spent = Number(totalSpent?.total ?? 0);
        const ratio = spent / budget.amountLimit;

        if (ratio >= 0.8) {
          // Anti-spam : ne pas recréer l'alerte si une notification
          // "budget_alert" non lue existe déjà pour ce budget.
          const recentAlerts = await notificationRepo.find({
            where: {
              userId: savedExpense.userId,
              type: 'budget_alert',
              isRead: false,
            },
          });

          const alreadyNotified = recentAlerts.some(
            (n) => n.data?.budgetId === budget.id
          );

          if (!alreadyNotified) {
            const notification = notificationRepo.create({
              userId: savedExpense.userId,
              title: 'Alerte Budget',
              body: `Vous avez atteint ${Math.round(ratio * 100)}% de votre budget "${budget.name ?? 'sans nom'}".`,
              type: 'budget_alert',
              relatedExpenseId: savedExpense.id,
              data: { budgetId: budget.id },
            });
            await notificationRepo.save(notification);
          }
        }
      }
    }

    const message = `La dépense a bien été enregistrée.`;
    return success(res, 201, savedExpense, message);
  } catch (error: any) {
    if (error instanceof ValidationError) {
      return generateServerErrorCode(
        res,
        400,
        error,
        'Les données de la dépense sont invalides.'
      );
    }

    return generateServerErrorCode(
      res,
      500,
      error,
      "La dépense n'a pas pu être ajoutée. Réessayez dans quelques instants."
    );
  }
};
// export const createExpense = async (req: Request, res: Response) => {
//   try {
//     const expenseRepository = myDataSource.getRepository(Expense);
//     const notificationRepo = myDataSource.getRepository(Notification);
//     const expense = expenseRepository.create(req.body as Partial<Expense>);
//     const savedExpense = (await expenseRepository.save(expense)) as Expense;

//     // Récupère le budget concerné (adapte selon ta relation Expense -> Budget)
//     const budget = await myDataSource.getRepository(Budget).findOne({
//       where: { id: savedExpense.budgetId },
//     });

//     if (budget) {
//       const totalSpent = await myDataSource
//         .getRepository(Expense)
//         .createQueryBuilder('e')
//         .where('e.budgetId = :budgetId', { budgetId: budget.id })
//         .select('SUM(e.amount)', 'total')
//         .getRawOne();

//       const spent = Number(totalSpent?.total ?? 0);
//       const ratio = spent / budget.amount;

//       if (ratio >= 0.8) {
//         const notification = notificationRepo.create({
//           userId: savedExpense.userId,
//           title: 'Alerte Budget',
//           body: `Vous avez atteint ${Math.round(ratio * 100)}% de votre budget "${budget.name}".`,
//           type: 'budget_alert',
//           relatedExpenseId: savedExpense.id,
//         });
//         await notificationRepo.save(notification);
//       }
//     }

//     const message = `La dépense a bien été enregistrée.`;
//     return success(res, 201, savedExpense, message);
//   } catch (error: any) {
//     if (error instanceof ValidationError) {
//       return generateServerErrorCode(
//         res,
//         400,
//         error,
//         'Les données de la dépense sont invalides.'
//       );
//     }

//     return generateServerErrorCode(
//       res,
//       500,
//       error,
//       "La dépense n'a pas pu être ajoutée. Réessayez dans quelques instants."
//     );
//   }
// };

// ====================== GET ALL ======================
export const getAllExpenses = async (req: Request, res: Response) => {
  try {
    const expenses = await myDataSource.getRepository(Expense).find({
      relations: ['category'],
      order: { date: 'DESC' }
    });

    const message = 'La liste des dépenses a bien été récupérée.';
    return success(res, 200, expenses, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La liste des dépenses n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== PAGINATED ======================
export const getExpensesPaginated = async (req: Request, res: Response) => {
  try {
    const { limit, searchTerm, startIndex } = paginationAndRechercheInit(
      req,
      Expense
    );

    let query = myDataSource
      .getRepository(Expense)
      .createQueryBuilder('e')
      .leftJoinAndSelect('e.category', 'category');

    if (searchTerm) {
      query = query.where(
        '( e.title ILIKE :keyword OR e.description ILIKE :keyword OR category.name ILIKE :keyword )',
        { keyword: `%${searchTerm}%` }
      );
    }

    const [data, totalElements] = await query
      .orderBy('e.date', 'DESC')
      .skip(startIndex)
      .take(limit)
      .getManyAndCount();

    const totalPages = Math.ceil(totalElements / limit);
    const message = 'La liste des dépenses a bien été récupérée.';

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
      'Erreur lors de la récupération des dépenses.'
    );
  }
};

// ====================== GET BY ID ======================
export const getExpenseById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const expense = await myDataSource.getRepository(Expense).findOne({
      where: { id: id as any },
      relations: ['category']
    });

    if (!expense) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "La dépense demandée n'existe pas."
      );
    }

    const message = 'La dépense a bien été trouvée.';
    return success(res, 200, expense, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La dépense n'a pas pu être récupérée. Réessayez dans quelques instants."
    );
  }
};

// ====================== UPDATE ======================
export const updateExpense = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const expenseRepository = myDataSource.getRepository(Expense);

    const expense = await expenseRepository.findOne({
      where: { id: id as any }
    });

    if (!expense) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "Cette dépense n'existe pas."
      );
    }

    expenseRepository.merge(expense, req.body);
    const updatedExpense = await expenseRepository.save(expense);

    const message = `La dépense a bien été modifiée.`;
    return success(res, 200, updatedExpense, message);
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
      "La dépense n'a pas pu être modifiée. Réessayez dans quelques instants."
    );
  }
};

// ====================== DELETE ======================
export const deleteExpense = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const expenseRepository = myDataSource.getRepository(Expense);

    const expense = await expenseRepository.findOne({
      where: { id: id as any }
    });

    if (!expense) {
      return generateServerErrorCode(
        res,
        404,
        "L'ID n'existe pas",
        "La dépense demandée n'existe pas."
      );
    }

    const hasRelations = await checkRelationsOneToMany('Expense', id);
    if (hasRelations) {
      return generateServerErrorCode(
        res,
        400,
        'Relations existantes',
        "Cette dépense est liée à d'autres enregistrements et ne peut pas être supprimée."
      );
    }

    await expenseRepository.remove(expense);

    const message = `La dépense a bien été supprimée.`;
    return success(res, 200, expense, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "La dépense n'a pas pu être supprimée. Réessayez dans quelques instants."
    );
  }
};