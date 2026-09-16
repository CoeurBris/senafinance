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
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllJournalOperations = exports.getAllJournalConnexions = void 0;
const data_source_1 = require("../../../configs/data-source");
const response_1 = require("../../../configs/response");
const paginationAndRechercheInit_1 = require("../../../configs/paginationAndRechercheInit");
const typeorm_1 = require("typeorm");
const journalConnexion_1 = require("../entity/journalConnexion");
const journalOperation_1 = require("../entity/journalOperation");
const getAllJournalConnexions = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { page, limit, searchTerm, startIndex, searchQueries } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, journalConnexion_1.JournalConnexion);
    let reque = yield data_source_1.myDataSource.getRepository(journalConnexion_1.JournalConnexion)
        .createQueryBuilder('journalConnexion')
        .orderBy('journalConnexion.id', 'DESC');
    if (searchQueries.length > 0) {
        reque.andWhere(new typeorm_1.Brackets(qb => {
            qb.where(searchQueries.join(' OR '), { keyword: `%${searchTerm}%` });
        }));
    }
    reque.skip(startIndex)
        .take(limit)
        .getManyAndCount()
        .then(([data, totalElements]) => {
        const message = 'La liste du journal de connexion a bien été récupéré.';
        const totalPages = Math.ceil(totalElements / limit);
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }).catch(error => {
        const message = `La liste du journal de connexion n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        //res.status(500).json({ message, data: error })
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getAllJournalConnexions = getAllJournalConnexions;
const getAllJournalOperations = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { page, limit, searchTerm, startIndex, searchQueries } = (0, paginationAndRechercheInit_1.paginationAndRechercheInit)(req, journalOperation_1.JournalOperation);
    let reque = yield data_source_1.myDataSource.getRepository(journalOperation_1.JournalOperation)
        .createQueryBuilder('journalOperation')
        .orderBy('journalOperation.id', 'DESC');
    if (searchQueries.length > 0) {
        reque.andWhere(new typeorm_1.Brackets(qb => {
            qb.where(searchQueries.join(' OR '), { keyword: `%${searchTerm}%` });
        }));
    }
    reque.skip(startIndex)
        .take(limit)
        .getManyAndCount()
        .then(([data, totalElements]) => {
        const message = 'La liste du journal d\'operation a bien été récupéré.';
        const totalPages = Math.ceil(totalElements / limit);
        return (0, response_1.success)(res, 200, { data, totalPages, totalElements, limit }, message);
    }).catch(error => {
        const message = `La liste du journal d\'operation n'a pas pu être récupéré. Réessayez dans quelques instants.`;
        //res.status(500).json({ message, data: error })
        return (0, response_1.generateServerErrorCode)(res, 500, error, message);
    });
});
exports.getAllJournalOperations = getAllJournalOperations;
