import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from '../entities';
import { IngestDto } from './dto/ingest.dto';
import { DiscussionService } from '../ai-pipeline/discussion.service';

@Injectable()
export class InternalService {
  constructor(
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
    private readonly discussionService: DiscussionService,
  ) {}

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
