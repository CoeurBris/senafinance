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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const user_entity_1 = require("../modules/gestiondesutilisateurs/entity/user.entity");
const data_source_1 = require("../configs/data-source");
class UserService {
    // Obtenir le repository TypeORM pour l'entité User
    static get userRepository() {
        return data_source_1.myDataSource.getRepository(user_entity_1.User);
    }
    // Trouver un utilisateur par e-mail
    static findByEmail(email) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield this.userRepository.findOne({
                where: { email },
            });
        });
    }
    // Créer un nouvel utilisateur
    static createUser(nom, email, motDePasse) {
        return __awaiter(this, void 0, void 0, function* () {
            const hashedPassword = yield bcrypt_1.default.hash(motDePasse, 10);
            // Création de l'instance en respectant la structure de l'entité User
            const newUser = this.userRepository.create({
                nom: nom,
                email: email,
                motDePasse: hashedPassword,
            });
            return yield this.userRepository.save(newUser);
        });
    }
}
exports.UserService = UserService;
