import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from '../entities/post.entity';
import { Comment } from '../entities/comment.entity';
import { Character, CharacterArchetype } from '../entities/character.entity';
import { CharacterMemory } from '../entities/character-memory.entity';
import { DiscussionDataPort, PostLike, CommentLike } from './discussion.service';
import { CharacterMemoryLike } from './memory.service';
import { CharacterId } from './characters.data';

/**
 * ai-pipeline의 문자열 CharacterId('PROPHET_HINDSIGHT' 등)와
 * DB Character 엔티티의 archetype enum(한글 명칭) 사이의 고정 매핑.
 * DiscussionService/MemoryService는 CharacterId만 알고, DB는 uuid PK + archetype만 안다.
 * 이 포트가 그 사이를 이어준다.
 */
export const ARCHETYPE_BY_CHARACTER_ID: Record<CharacterId, CharacterArchetype> = {
  PROPHET_HINDSIGHT: CharacterArchetype.HINDSIGHT_PROPHET,
  MOCKER: CharacterArchetype.MOCKING_TROUBLEMAKER,
  CAMP_FRAMER: CharacterArchetype.CAMP_FRAMER,
  FACT_LECTURER: CharacterArchetype.LONGWINDED_FACT_CHECKER,
  QUALIFICATION_ATTACKER: CharacterArchetype.CREDENTIAL_GATEKEEPER,
  MORAL_PREACHER: CharacterArchetype.MORAL_PREACHER,
  DOOM_AGITATOR: CharacterArchetype.DOOM_AGITATOR,
  BANDWAGON: CharacterArchetype.BANDWAGON_RIDER,
};

/**
 * DiscussionDataPort의 실제 TypeORM 구현체.
 * Post/Comment/Character/CharacterMemory 리포지토리를 사용하며,
 * CharacterId ↔ Character.uuid 매핑을 시드된 characters 테이블에서 한 번 로드해 캐시한다.
 */
@Injectable()
export class TypeOrmDiscussionDataPort implements DiscussionDataPort {
  private uuidByCharacterId = new Map<CharacterId, string>();
  private characterIdByUuid = new Map<string, CharacterId>();
  private mapsLoaded = false;

  constructor(
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
    @InjectRepository(Comment) private readonly commentRepo: Repository<Comment>,
    @InjectRepository(Character) private readonly characterRepo: Repository<Character>,
    @InjectRepository(CharacterMemory) private readonly memoryRepo: Repository<CharacterMemory>,
  ) {}

  private async ensureMaps(): Promise<void> {
    if (this.mapsLoaded) {
      return;
    }
    const characters = await this.characterRepo.find();
    const uuidByArchetype = new Map<CharacterArchetype, string>();
    for (const ch of characters) {
      uuidByArchetype.set(ch.archetype, ch.id);
    }
    for (const [characterId, archetype] of Object.entries(ARCHETYPE_BY_CHARACTER_ID) as [
      CharacterId,
      CharacterArchetype,
    ][]) {
      const uuid = uuidByArchetype.get(archetype);
      if (uuid) {
        this.uuidByCharacterId.set(characterId, uuid);
        this.characterIdByUuid.set(uuid, characterId);
      }
    }
    this.mapsLoaded = true;
  }

  private async toUuid(characterId: CharacterId): Promise<string> {
    await this.ensureMaps();
    const uuid = this.uuidByCharacterId.get(characterId);
    if (!uuid) {
      throw new Error(
        `Character not found in DB for id "${characterId}". characters 테이블이 시드됐는지 확인하세요 (npm run seed).`,
      );
    }
    return uuid;
  }

  async getPost(postId: string): Promise<PostLike> {
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (!post) {
      throw new Error(`Post not found: ${postId}`);
    }
    return { id: post.id, sourceText: post.sourceText, tags: post.tags ?? [] };
  }

  async getExistingComments(postId: string): Promise<CommentLike[]> {
    await this.ensureMaps();
    const comments = await this.commentRepo.find({
      where: { postId },
      order: { roundNumber: 'ASC', createdAt: 'ASC' },
    });
    const result: CommentLike[] = [];
    for (const c of comments) {
      const characterId = this.characterIdByUuid.get(c.characterId);
      if (!characterId) {
        continue; // 매핑되지 않는(시드 외) 캐릭터의 댓글은 스레드 컨텍스트에서 제외
      }
      result.push({
        id: c.id,
        postId: c.postId,
        characterId,
        roundNumber: c.roundNumber,
        content: c.content,
      });
    }
    return result;
  }

  async saveComment(comment: CommentLike): Promise<CommentLike> {
    const characterUuid = await this.toUuid(comment.characterId);
    const entity = this.commentRepo.create({
      postId: comment.postId,
      characterId: characterUuid,
      roundNumber: comment.roundNumber,
      content: comment.content,
    });
    const saved = await this.commentRepo.save(entity);
    return {
      id: saved.id,
      postId: saved.postId,
      characterId: comment.characterId,
      roundNumber: saved.roundNumber,
      content: saved.content,
    };
  }

  async getMemory(characterId: CharacterId): Promise<CharacterMemoryLike | null> {
    const characterUuid = await this.toUuid(characterId);
    const memory = await this.memoryRepo.findOne({ where: { characterId: characterUuid } });
    if (!memory) {
      return null;
    }
    return { characterId, summarizedStance: memory.summarizedStance };
  }

  async saveMemory(memory: CharacterMemoryLike): Promise<void> {
    const characterUuid = await this.toUuid(memory.characterId);
    const existing = await this.memoryRepo.findOne({ where: { characterId: characterUuid } });
    if (existing) {
      existing.summarizedStance = memory.summarizedStance;
      await this.memoryRepo.save(existing);
      return;
    }
    await this.memoryRepo.save(
      this.memoryRepo.create({
        characterId: characterUuid,
        summarizedStance: memory.summarizedStance,
      }),
    );
  }
}
