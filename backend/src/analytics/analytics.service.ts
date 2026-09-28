import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment, CharacterPostInterest } from '../entities';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(Comment) private readonly commentRepo: Repository<Comment>,
    @InjectRepository(CharacterPostInterest)
    private readonly interestRepo: Repository<CharacterPostInterest>,
  ) {}

  /**
   * 에이전트 간 대화량: 대댓글(parent_comment_id) 기준으로,
   * "누가(from) 누구에게(to) 몇 번 답글을 달았는지" 집계.
   */
  async agentInteractions(): Promise<
    Array<{ fromId: string; fromName: string; toId: string; toName: string; count: number }>
  > {
    return this.commentRepo.query(`
      SELECT
        cc.id   AS "fromId",
        cc.name AS "fromName",
        pc.id   AS "toId",
        pc.name AS "toName",
        COUNT(*)::int AS "count"
      FROM comments child
      JOIN comments parent ON child.parent_comment_id = parent.id
      JOIN characters cc ON child.character_id = cc.id
      JOIN characters pc ON parent.character_id = pc.id
      WHERE cc.id <> pc.id
      GROUP BY cc.id, cc.name, pc.id, pc.name
      ORDER BY "count" DESC
    `);
  }

  /** 에이전트별 관심(열람) 게시글 수, 관심 많이 받은 게시글 순위. */
  async interestOverview(): Promise<{
    perCharacter: Array<{ characterId: string; characterName: string; viewedPosts: number }>;
    topPosts: Array<{ postId: string; sourceText: string; interestedAgents: number }>;
  }> {
    const perCharacter = await this.interestRepo.query(`
      SELECT c.id AS "characterId", c.name AS "characterName", COUNT(*)::int AS "viewedPosts"
      FROM character_post_interests i
      JOIN characters c ON i.character_id = c.id
      GROUP BY c.id, c.name
      ORDER BY "viewedPosts" DESC
    `);
    const topPosts = await this.interestRepo.query(`
      SELECT p.id AS "postId", left(p.source_text, 60) AS "sourceText", COUNT(*)::int AS "interestedAgents"
      FROM character_post_interests i
      JOIN posts p ON i.post_id = p.id
      GROUP BY p.id, p.source_text
      ORDER BY "interestedAgents" DESC
      LIMIT 10
    `);
    return { perCharacter, topPosts };
  }
}
