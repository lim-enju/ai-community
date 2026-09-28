import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post, CharacterPostInterest } from '../entities';
import { IngestDto } from './dto/ingest.dto';
import { DiscussionService } from '../ai-pipeline/discussion.service';

@Injectable()
export class InternalService {
  constructor(
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
    @InjectRepository(CharacterPostInterest)
    private readonly interestRepo: Repository<CharacterPostInterest>,
    private readonly discussionService: DiscussionService,
  ) {}

  /**
   * 에이전트가 게시글을 "조회"했음을 기록한다.
   * - 조회수(viewCount) +1 (사람이 아닌 에이전트의 열람도 조회수에 반영)
   * - character_post_interests에 관심(열람) 기록 upsert (같은 에이전트-게시글은 중복 없이 최초 1회)
   * 댓글 작성은 별개다. 에이전트는 글을 보고(=이 기록) 댓글을 달 수도, 그냥 눈팅만 할 수도 있다.
   */
  async recordAgentView(
    postId: string,
    characterId: string,
    note?: string,
  ): Promise<{ postId: string; characterId: string; viewCount: number; newInterest: boolean }> {
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (!post) {
      throw new NotFoundException(`Post not found: ${postId}`);
    }

    await this.postRepo.increment({ id: postId }, 'viewCount', 1);

    const existing = await this.interestRepo.findOne({ where: { postId, characterId } });
    let newInterest = false;
    if (!existing) {
      await this.interestRepo.save(
        this.interestRepo.create({ postId, characterId, note: note ?? null }),
      );
      newInterest = true;
    }

    return { postId, characterId, viewCount: post.viewCount + 1, newInterest };
  }

  /**
   * Stub: persists a Post from already-obtained source text/url. The actual
   * fetching/crawling of source content and any content moderation is handled
   * entirely by the AI content pipeline agent before calling this endpoint.
   * No AI generation happens here.
   */
  async ingest(dto: IngestDto): Promise<Post> {
    const post = this.postRepo.create({
      boardId: dto.boardId,
      sourceText: dto.sourceText,
      sourceUrl: dto.sourceUrl ?? null,
      tags: dto.tags ?? [],
    });
    return this.postRepo.save(post);
  }

  /**
   * 주어진 게시글에 대해 ai-pipeline의 DiscussionService를 호출해
   * 캐릭터별 라운드 토론(댓글)을 생성·저장한다. Claude API를 실제로 호출하므로
   * 비용이 발생한다 (ANTHROPIC_API_KEY 필요).
   */
  async generateComments(
    postId: string,
  ): Promise<{ postId: string; status: string; commentCount: number }> {
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (!post) {
      throw new NotFoundException(`Post not found: ${postId}`);
    }

    const comments = await this.discussionService.generateDiscussionForPost(postId);
    return { postId, status: 'generated', commentCount: comments.length };
  }
}
