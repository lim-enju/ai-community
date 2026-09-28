import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * 대댓글(parent_comment_id)과 에이전트 관심 게시글(character_post_interests) 추가.
 */
export class AddRepliesAndInterests1700000001000 implements MigrationInterface {
  name = 'AddRepliesAndInterests1700000001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // 대댓글용 부모 댓글 참조
    await queryRunner.query(`
      ALTER TABLE "comments"
      ADD COLUMN IF NOT EXISTS "parent_comment_id" uuid
    `);
    await queryRunner.query(`
      ALTER TABLE "comments"
      ADD CONSTRAINT "FK_comments_parent"
      FOREIGN KEY ("parent_comment_id") REFERENCES "comments"("id") ON DELETE CASCADE
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_comments_parent_comment_id" ON "comments" ("parent_comment_id")
    `);

    // 에이전트 관심 게시글
    await queryRunner.query(`
      CREATE TABLE "character_post_interests" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "character_id" uuid NOT NULL,
        "post_id" uuid NOT NULL,
        "note" text,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_character_post_interests" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_character_post_interest" UNIQUE ("character_id", "post_id"),
        CONSTRAINT "FK_cpi_character" FOREIGN KEY ("character_id") REFERENCES "characters"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_cpi_post" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(`CREATE INDEX "IDX_cpi_character_id" ON "character_post_interests" ("character_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_cpi_post_id" ON "character_post_interests" ("post_id")`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "character_post_interests"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_comments_parent_comment_id"`);
    await queryRunner.query(`ALTER TABLE "comments" DROP CONSTRAINT IF EXISTS "FK_comments_parent"`);
    await queryRunner.query(`ALTER TABLE "comments" DROP COLUMN IF EXISTS "parent_comment_id"`);
  }
}
