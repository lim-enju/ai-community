import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from '../entities';
import { IngestDto } from './dto/ingest.dto';

@Injectable()
export class InternalService {
  constructor(@InjectRepository(Post) private readonly postRepo: Repository<Post>) {}

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
   * Stub trigger point: the AI content pipeline agent will implement the
   * actual character comment generation logic behind this endpoint. For now
   * it only validates the post exists and returns a not-implemented style ack.
   */
  async generateComments(postId: string): Promise<{ postId: string; status: string }> {
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (!post) {
      throw new NotFoundException(`Post not found: ${postId}`);
    }

    // TODO(ai-pipeline agent): generate Comment rows per round using Character
    // personas and CharacterMemory, calling the Claude API. Not implemented here.
    return { postId, status: 'not_implemented' };
  }
}
