import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateObjectifsTable1789386092173 implements MigrationInterface {
    name = 'CreateObjectifsTable1789386092173'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "objectifs" ("id" SERIAL NOT NULL, "userId" integer, "title" character varying(255) NOT NULL, "targetAmount" numeric(12,2) NOT NULL, "currentAmount" numeric(12,2) NOT NULL DEFAULT '0', "targetDate" TIMESTAMP, "description" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_ae81453bb8c79cf4cab68d69bc4" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "objectifs" ADD CONSTRAINT "FK_c2de39ad626235cc4a7f13e1cea" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "objectifs" DROP CONSTRAINT "FK_c2de39ad626235cc4a7f13e1cea"`);
        await queryRunner.query(`DROP TABLE "objectifs"`);
    }

}
