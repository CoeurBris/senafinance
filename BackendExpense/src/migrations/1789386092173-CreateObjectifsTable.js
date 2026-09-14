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
exports.CreateObjectifsTable1789386092173 = void 0;
class CreateObjectifsTable1789386092173 {
    constructor() {
        this.name = 'CreateObjectifsTable1789386092173';
    }
    up(queryRunner) {
        return __awaiter(this, void 0, void 0, function* () {
            yield queryRunner.query(`CREATE TABLE "objectifs" ("id" SERIAL NOT NULL, "userId" integer, "title" character varying(255) NOT NULL, "targetAmount" numeric(12,2) NOT NULL, "currentAmount" numeric(12,2) NOT NULL DEFAULT '0', "targetDate" TIMESTAMP, "description" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_ae81453bb8c79cf4cab68d69bc4" PRIMARY KEY ("id"))`);
            yield queryRunner.query(`ALTER TABLE "objectifs" ADD CONSTRAINT "FK_c2de39ad626235cc4a7f13e1cea" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        });
    }
    down(queryRunner) {
        return __awaiter(this, void 0, void 0, function* () {
            yield queryRunner.query(`ALTER TABLE "objectifs" DROP CONSTRAINT "FK_c2de39ad626235cc4a7f13e1cea"`);
            yield queryRunner.query(`DROP TABLE "objectifs"`);
        });
    }
}
exports.CreateObjectifsTable1789386092173 = CreateObjectifsTable1789386092173;
