import { Injectable } from '@nestjs/common';
import { DiscussionDataPort, PostLike, CommentLike } from './discussion.service';
import { CharacterMemoryLike } from './memory.service';
import { CharacterId } from './characters.data';

/**
 * DiscussionDataPort의 임시 in-memory 구현체.
 *
 * 실제 Post/Comment/CharacterMemory 리포지토리(TypeORM)가 아직 확정되지 않았거나 연결되지 않은
 * 환경에서 ai-pipeline 모듈을 독립적으로 실행/테스트하기 위한 용도. 시드용 게시글을 미리 등록해두고
 * (seedPost) 사용한다. 실제 DB 연동 시에는 ai-pipeline.module.ts의 provider를
 * TypeOrmDiscussionDataPort 같은 실제 구현체로 교체하면 된다.
 */
@Injectable()
export class InMemoryDiscussionDataPort implements DiscussionDataPort {
  private posts = new Map<string, PostLike>();
  private comments: CommentLike[] = [];
  private memories = new Map<CharacterId, CharacterMemoryLike>();

  /** 테스트/데모용으로 게시글을 미리 등록한다. */
  seedPost(post: PostLike): void {
    this.posts.set(post.id, post);
  }

  async getPost(postId: string): Promise<PostLike> {
    const post = this.posts.get(postId);
    if (!post) {
      throw new Error(`Post not found: ${postId} (InMemoryDiscussionDataPort.seedPost로 먼저 등록하세요)`);
    }
    return post;
  }

  async getExistingComments(postId: string): Promise<CommentLike[]> {
    return this.comments.filter((c) => c.postId === postId);
  }

  async saveComment(comment: CommentLike): Promise<CommentLike> {
    const saved = { ...comment, id: comment.id ?? `${this.comments.length + 1}` };
    this.comments.push(saved);
    return saved;
  }

  async getMemory(characterId: CharacterId): Promise<CharacterMemoryLike | null> {
    return this.memories.get(characterId) ?? null;
  }

  async saveMemory(memory: CharacterMemoryLike): Promise<void> {
    this.memories.set(memory.characterId, memory);
  }
}
