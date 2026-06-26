import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Adds user accounts and scopes documents + quizzes to their owner.
 *   - creates the "user" table
 *   - adds a nullable "userId" FK to "document" and "quiz"
 *
 * Existing rows keep userId NULL (orphaned); new data is always owned.
 */
export class AddUsers1714000001000 implements MigrationInterface {
  name = 'AddUsers1714000001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "user" (
        "id"           SERIAL PRIMARY KEY,
        "email"        varchar NOT NULL,
        "passwordHash" varchar NOT NULL,
        "name"         varchar,
        "createdAt"    TIMESTAMP NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS "IDX_user_email" ON "user" ("email")
    `);

    // document.userId
    await queryRunner.query(`
      ALTER TABLE "document" ADD COLUMN IF NOT EXISTS "userId" integer
    `);
    await queryRunner.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint WHERE conname = 'FK_document_user'
        ) THEN
          ALTER TABLE "document"
            ADD CONSTRAINT "FK_document_user"
            FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE;
        END IF;
      END$$;
    `);

    // quiz.userId
    await queryRunner.query(`
      ALTER TABLE "quiz" ADD COLUMN IF NOT EXISTS "userId" integer
    `);
    await queryRunner.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint WHERE conname = 'FK_quiz_user'
        ) THEN
          ALTER TABLE "quiz"
            ADD CONSTRAINT "FK_quiz_user"
            FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE;
        END IF;
      END$$;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "quiz" DROP CONSTRAINT IF EXISTS "FK_quiz_user"`);
    await queryRunner.query(`ALTER TABLE "quiz" DROP COLUMN IF EXISTS "userId"`);
    await queryRunner.query(`ALTER TABLE "document" DROP CONSTRAINT IF EXISTS "FK_document_user"`);
    await queryRunner.query(`ALTER TABLE "document" DROP COLUMN IF EXISTS "userId"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_user_email"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "user"`);
  }
}
