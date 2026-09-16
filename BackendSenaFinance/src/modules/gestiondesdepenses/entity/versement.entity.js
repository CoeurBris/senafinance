"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Versement = void 0;
const typeorm_1 = require("typeorm");
const objectif_entity_1 = require("./objectif.entity");
let Versement = class Versement {
};
exports.Versement = Versement;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Versement.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int' }),
    __metadata("design:type", Number)
], Versement.prototype, "objectifId", void 0);
__decorate([
    (0, typeorm_1.Column)('decimal', { precision: 12, scale: 2 }),
    __metadata("design:type", Number)
], Versement.prototype, "montant", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Versement.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => objectif_entity_1.Objectif, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'objectifId' }),
    __metadata("design:type", objectif_entity_1.Objectif)
], Versement.prototype, "objectif", void 0);
exports.Versement = Versement = __decorate([
    (0, typeorm_1.Entity)('versements')
], Versement);
