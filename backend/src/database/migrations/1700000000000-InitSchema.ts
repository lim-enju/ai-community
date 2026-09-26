import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitSchema1700000000000 implements MigrationInterface {
  name = 'InitSchema1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`);

    await queryRunner.query(`
      CREATE TABLE "boards" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "name" varchar(100) NOT NULL,
        "slug" varchar(100) NOT NULL,
        "description" text,
        CONSTRAINT "PK_boards" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_boards_slug" UNIQUE ("slug")
      )
    `);

    await queryRunner.query(`
      CREATE TYPE "characters_archetype_enum" AS ENUM (
        '결과론 예언자',
        '비꼴·조롱형 시비꾼',
        '진영 프레이머',
        '장문 팩트 교정러',
        '자격 검증형',
        '당위 설교자',
        '비관 선동형',
        '분위기 편승형'
      )
    `);

    await queryRunner.query(`
      CREATE TABLE "characters" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "name" varchar(100) NOT NULL,
        "archetype" "characters_archetype_enum" NOT NULL,
        "speech_examples" text[] NOT NULL DEFAULT '{}',
        "personality" text NOT NULL,
        "argument_pattern" text NOT NULL,
        "response_length_guide" text NOT NULL,
        CONSTRAINT "PK_characters" PRIMARY KEY ("id")
      )
    `);

    await queryRunner.query(`
      CREATE TABLE "posts" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "board_id" uuid NOT NULL,
        "source_text" text NOT NULL,
        "source_url" varchar(2048),
        "tags" text[] NOT NULL DEFAULT '{}',
        "view_count" int NOT NULL DEFAULT 0,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_posts" PRIMARY KEY ("id"),
        CONSTRAINT "FK_posts_board" FOREIGN KEY ("board_id") REFERENCES "boards"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(`CREATE INDEX "IDX_posts_tags" ON "posts" USING GIN ("tags")`);
    await queryRunner.query(`CREATE INDEX "IDX_posts_board_id" ON "posts" ("board_id")`);

    await queryRunner.query(`
      CREATE TABLE "comments" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "post_id" uuid NOT NULL,
        "character_id" uuid NOT NULL,
        "round_number" int NOT NULL,
        "content" text NOT NULL,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_comments" PRIMARY KEY ("id"),
        CONSTRAINT "FK_comments_post" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_comments_character" FOREIGN KEY ("character_id") REFERENCES "characters"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(`CREATE INDEX "IDX_comments_post_id" ON "comments" ("post_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_comments_round_number" ON "comments" ("round_number")`);

    await queryRunner.query(`
      CREATE TABLE "character_memories" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "character_id" uuid NOT NULL,
        "summarized_stance" text NOT NULL,
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_character_memories" PRIMARY KEY ("id"),
        CONSTRAINT "FK_character_memories_character" FOREIGN KEY ("character_id") REFERENCES "characters"("id") ON DELETE CASCADE
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "character_memories"`);
    await queryRunner.query(`DROP TABLE "comments"`);
    await queryRunner.query(`DROP TABLE "posts"`);
    await queryRunner.query(`DROP TABLE "characters"`);
    await queryRunner.query(`DROP TYPE "characters_archetype_enum"`);
    await queryRunner.query(`DROP TABLE "boards"`);
  }
}
