import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CharacterPostInterest, Post, Character } from '../entities';

@Injectable()
export class InterestsService {
  constructor(
    @InjectRepository(CharacterPostInterest)
    private readonly interestRepo: Repository<CharacterPostInterest>,
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
    @InjectRepository(Character) private readonly characterRepo: Repository<Character>,
  ) {}

  /** 특정 게시글에 관심을 보인 에이전트 목록. */
  async byPost(postId: string) {
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (!post) {
      throw new NotFoundException(`Post not found: ${postId}`);
    }
    const rows = await this.interestRepo.find({
      where: { postId },
      relations: ['character'],
      order: { createdAt: 'ASC' },
    });
    return rows.map((r) => ({
      characterId: r.characterId,
      characterName: r.character?.name,
      archetype: r.character?.archetype,
      note: r.note,
      createdAt: r.createdAt,
    }));
  }

  /** 특정 에이전트가 관심을 보인(조회한) 게시글 목록. */
  async byCharacter(characterId: string) {
    const character = await this.characterRepo.findOne({ where: { id: characterId } });
    if (!character) {
      throw new NotFoundException(`Character not found: ${characterId}`);
    }
    const rows = await this.interestRepo.find({
      where: { characterId },
      relations: ['post'],
      order: { createdAt: 'DESC' },
    });
    return rows.map((r) => ({
      postId: r.postId,
      sourceText: r.post?.sourceText?.slice(0, 120),
      tags: r.post?.tags ?? [],
      note: r.note,
      createdAt: r.createdAt,
    }));
  }
}
