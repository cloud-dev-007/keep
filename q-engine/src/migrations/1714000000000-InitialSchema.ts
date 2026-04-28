import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Initial schema migration. Captures the entity model that previously lived
 * behind `synchronize: true` so we have an explicit, replayable baseline.
 *
 * NOTE: the `vectorstore` table that LangChain's PGVectorStore uses is
 * created on demand by `PGVectorStore.initialize()` (called from
 * VectorStoreService.onModuleInit). We only need to make sure the
 * `vector` extension is installed here.
 */
export class InitialSchema1714000000000 implements MigrationInterface {
  name = 'InitialSchema1714000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // pgvector extension — required for the LangChain vectorstore table.
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS vector`);

    // ---- enum: quiz.type ---------------------------------------------------
    await queryRunner.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'quiz_type_enum') THEN
          CREATE TYPE "quiz_type_enum" AS ENUM ('MCQ', 'FillInTheBlank', 'TrueFalse', 'Theory', 'Any');
        END IF;
      END$$;
    `);

    // ---- document ----------------------------------------------------------
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "document" (
        "id"          SERIAL PRIMARY KEY,
        "title"       varchar,
        "description" varchar,
        "topics"      text[],
        "formatType"  varchar NOT NULL,
        "fileName"    varchar NOT NULL,
        "filePath"    varchar NOT NULL,
        "pageCount"   integer,
        "createdAt"   TIMESTAMP NOT NULL DEFAULT now()
      )
    `);

    // ---- quiz --------------------------------------------------------------
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "quiz" (
        "id"            SERIAL PRIMARY KEY,
        "title"         varchar,
        "difficulty"    integer NOT NULL,
        "duration"      integer,
        "noOfQuestions" integer NOT NULL,
        "isAdaptive"    boolean,
        "type"          quiz_type_enum NOT NULL,
        "createdAt"     TIMESTAMP NOT NULL DEFAULT now()
      )
    `);

    // ---- quiz_question -----------------------------------------------------
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "quiz_question" (
        "id"       SERIAL PRIMARY KEY,
        "type"     varchar NOT NULL,
        "question" text NOT NULL,
        "answer"   text,
        "quizId"   integer
      )
    `);
    await queryRunner.query(`
      ALTER TABLE "quiz_question"
      ADD CONSTRAINT "fk_quiz_question_quiz"
      FOREIGN KEY ("quizId") REFERENCES "quiz"("id") ON DELETE NO ACTION
    `);

    // ---- quiz_option -------------------------------------------------------
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "quiz_option" (
        "id"         SERIAL PRIMARY KEY,
        "value"      varchar NOT NULL,
        "isAnswer"   boolean NOT NULL,
        "questionId" integer
      )
    `);
    await queryRunner.query(`
      ALTER TABLE "quiz_option"
      ADD CONSTRAINT "fk_quiz_option_question"
      FOREIGN KEY ("questionId") REFERENCES "quiz_question"("id") ON DELETE NO ACTION
    `);

    // ---- quiz_attempt ------------------------------------------------------
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "quiz_attempt" (
        "id"         SERIAL PRIMARY KEY,
        "quizId"     integer,
        "accuracy"   real,
        "timeTaken"  integer,
        "weakTopics" text[],
        "analysis"   text,
        "difficulty" integer,
        "createdAt"  TIMESTAMP NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(`
      ALTER TABLE "quiz_attempt"
      ADD CONSTRAINT "fk_quiz_attempt_quiz"
      FOREIGN KEY ("quizId") REFERENCES "quiz"("id") ON DELETE NO ACTION
    `);

    // ---- question_attempt --------------------------------------------------
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "question_attempt" (
        "id"         SERIAL PRIMARY KEY,
        "value"      varchar NOT NULL,
        "correct"    boolean NOT NULL,
        "questionId" integer NOT NULL,
        "historyId"  integer
      )
    `);
    await queryRunner.query(`
      ALTER TABLE "question_attempt"
      ADD CONSTRAINT "fk_question_attempt_question"
      FOREIGN KEY ("questionId") REFERENCES "quiz_question"("id") ON DELETE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE "question_attempt"
      ADD CONSTRAINT "fk_question_attempt_history"
      FOREIGN KEY ("historyId") REFERENCES "quiz_attempt"("id") ON DELETE NO ACTION
    `);

    // ---- quiz <-> document join (ManyToMany generates "quiz_documents_document") ----
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "quiz_documents_document" (
        "quizId"     integer NOT NULL,
        "documentId" integer NOT NULL,
        PRIMARY KEY ("quizId", "documentId")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "idx_quiz_documents_quiz"
      ON "quiz_documents_document" ("quizId")
    `);
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "idx_quiz_documents_document"
      ON "quiz_documents_document" ("documentId")
    `);
    await queryRunner.query(`
      ALTER TABLE "quiz_documents_document"
      ADD CONSTRAINT "fk_qdd_quiz"
      FOREIGN KEY ("quizId") REFERENCES "quiz"("id") ON DELETE CASCADE ON UPDATE CASCADE
    `);
    await queryRunner.query(`
      ALTER TABLE "quiz_documents_document"
      ADD CONSTRAINT "fk_qdd_document"
      FOREIGN KEY ("documentId") REFERENCES "document"("id") ON DELETE CASCADE
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "quiz_documents_document"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "question_attempt"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "quiz_attempt"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "quiz_option"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "quiz_question"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "quiz"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "document"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "quiz_type_enum"`);
    // Note: we deliberately leave the pgvector extension in place; dropping it
    // would also drop the vectorstore table that LangChain manages.
  }
}
