import { Request, Response } from 'express';
import { verify } from 'jsonwebtoken';
import { myDataSource } from '../../../configs/data-source';
import { generateServerErrorCode, success } from '../../../configs/response';
import { config } from '../../../configs/config';
import { Budget } from '../entity/budget.entity';
import { Expense } from '../entity/expense.entity';
import { User } from '../../gestiondesutilisateurs/entity/user.entity';

// ====================== GET DASHBOARD ======================
export const getDashboardData = async (req: Request, res: Response) => {
  try {
    // --- Récupération de l'utilisateur connecté via le token JWT ---
    const authHeader = req.headers.authorization;
    const token =
      authHeader && authHeader.startsWith('Bearer ')
        ? authHeader.split(' ')[1]
        : null;

    if (!token) {
      return generateServerErrorCode(
        res,
        401,
        'session',
        'Jeton manquant. Veuillez vous reconnecter.'
      );
    }

    let payload: any;
    try {
      payload = verify(token, config.jwt.accessToken);
    } catch (err) {
      return generateServerErrorCode(
        res,
        401,
        'session',
        'Votre session a expiré, veuillez vous reconnecter.'
      );
    }

    const userId = payload.userId;

    const userRepository = myDataSource.getRepository(User);
    const user = await userRepository.findOne({ where: { id: userId } });

    if (!user) {
      return generateServerErrorCode(
        res,
        404,
        'user',
        'Utilisateur introuvable.'
      );
    }

    const { password, ...userData } = user as any;

    // --- Budgets de l'utilisateur ---
    const budgetRepository = myDataSource.getRepository(Budget);
    const budgets = await budgetRepository.find({
      where: { userId },
      relations: ['category'],
      order: { id: 'DESC' as any },
    });

    const totalBudget = budgets.reduce(
      (sum, b) => sum + Number(b.amountLimit || 0),
      0
    );

    // --- Dépenses de l'utilisateur ---
    const expenseRepository = myDataSource.getRepository(Expense);
    const expenses = await expenseRepository.find({
      where: { userId: userId?.toString() },
      relations: ['category'],
      order: { date: 'DESC' as any },
    });

    const totalExpenses = expenses.reduce(
      (sum, e) => sum + Number(e.amount || 0),
      0
    );

    const recentExpenses = expenses.slice(0, 5).map((e) => ({
      id: e.id,
      title: e.title,
      amount: e.amount,
      date: e.date,
      category: e.category?.name ?? null,
      categoryId: e.categoryId ?? null,
    }));

    const data = {
      total_budget: totalBudget,
      total_expenses: totalExpenses,
      remaining_budget: totalBudget - totalExpenses,
      recent_expenses: recentExpenses,
      budgets,
      user: {
        id: userData.id,
        name: userData.nom,
        email: userData.email,
        // ⚠️ adapte le nom de la colonne si ton entité User utilise
        // un autre champ pour l'avatar (ex: photoUrl, avatarUrl...)
        photo_url: userData.photo_url ?? userData.photoUrl ?? null,
      },
    };

    const message = 'Les données du tableau de bord ont bien été récupérées.';
    return success(res, 200, data, message);
  } catch (error: any) {
    return generateServerErrorCode(
      res,
      500,
      error,
      "Les données du tableau de bord n'ont pas pu être récupérées. Réessayez dans quelques instants."
    );
  }
};