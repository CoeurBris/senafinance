"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDashboardData = void 0;
const jsonwebtoken_1 = require("jsonwebtoken");
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const config_1 = require("../../../configs/config");
const budget_entity_1 = require("../entity/budget.entity");
const expense_entity_1 = require("../entity/expense.entity");
const user_entity_1 = require("../../gestiondesutilisateurs/entity/user.entity");
// ====================== GET DASHBOARD ======================
const getDashboardData = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    try {
        // --- Récupération de l'utilisateur connecté via le token JWT ---
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.startsWith('Bearer ')
            ? authHeader.split(' ')[1]
            : null;
        if (!token) {
            return (0, response_1.generateServerErrorCode)(res, 401, 'session', 'Jeton manquant. Veuillez vous reconnecter.');
        }
        let payload;
        try {
            payload = (0, jsonwebtoken_1.verify)(token, config_1.config.jwt.accessToken);
        }
        catch (err) {
            return (0, response_1.generateServerErrorCode)(res, 401, 'session', 'Votre session a expiré, veuillez vous reconnecter.');
        }
        const userId = payload.userId;
        const userRepository = data_source_1.myDataSource.getRepository(user_entity_1.User);
        const user = yield userRepository.findOne({ where: { id: userId } });
        if (!user) {
            return (0, response_1.generateServerErrorCode)(res, 404, 'user', 'Utilisateur introuvable.');
        }
        const _c = user, { password } = _c, userData = __rest(_c, ["password"]);
        // --- Budgets de l'utilisateur ---
        const budgetRepository = data_source_1.myDataSource.getRepository(budget_entity_1.Budget);
        const budgets = yield budgetRepository.find({
            where: { userId },
            relations: ['category'],
            order: { id: 'DESC' },
        });
        const totalBudget = budgets.reduce((sum, b) => sum + Number(b.amountLimit || 0), 0);
        // --- Dépenses de l'utilisateur ---
        const expenseRepository = data_source_1.myDataSource.getRepository(expense_entity_1.Expense);
        const expenses = yield expenseRepository.find({
            where: { userId: userId === null || userId === void 0 ? void 0 : userId.toString() },
            relations: ['category'],
            order: { date: 'DESC' },
        });
        const totalExpenses = expenses.reduce((sum, e) => sum + Number(e.amount || 0), 0);
        const recentExpenses = expenses.slice(0, 5).map((e) => {
            var _a, _b, _c;
            return ({
                id: e.id,
                title: e.title,
                amount: e.amount,
                date: e.date,
                category: (_b = (_a = e.category) === null || _a === void 0 ? void 0 : _a.name) !== null && _b !== void 0 ? _b : null,
                categoryId: (_c = e.categoryId) !== null && _c !== void 0 ? _c : null,
            });
        });
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
                photo_url: (_b = (_a = userData.photo_url) !== null && _a !== void 0 ? _a : userData.photoUrl) !== null && _b !== void 0 ? _b : null,
            },
        };
        const message = 'Les données du tableau de bord ont bien été récupérées.';
        return (0, response_1.success)(res, 200, data, message);
    }
    catch (error) {
        return (0, response_1.generateServerErrorCode)(res, 500, error, "Les données du tableau de bord n'ont pas pu être récupérées. Réessayez dans quelques instants.");
    }
});
exports.getDashboardData = getDashboardData;
