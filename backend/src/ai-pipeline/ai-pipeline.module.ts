import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post } from '../entities/post.entity';
import { Comment } from '../entities/comment.entity';
import { Character } from '../entities/character.entity';
import { CharacterMemory } from '../entities/character-memory.entity';
import { DISCUSSION_DATA_PORT, DiscussionDataPort, DiscussionService } from './discussion.service';
import { MemoryService } from './memory.service';
import { TypeOrmDiscussionDataPort } from './typeorm-data-port';

/**
 * ai-pipeline 모듈.
 *
 * DiscussionService는 DISCUSSION_DATA_PORT 토큰을 통해서만 데이터에 접근한다 (discussion.service.ts
 * 참고). 실제 DB 연동은 TypeOrmDiscussionDataPort가 담당하며, Post/Comment/Character/CharacterMemory
 * 리포지토리를 TypeOrmModule.forFeature로 주입받는다.
 *
 * (독립 실행/단위 테스트용 InMemoryDiscussionDataPort는 in-memory-data-port.ts에 그대로 남겨뒀으니,
 *  DB 없이 파이프라인만 돌려보고 싶을 땐 provider를 그쪽으로 바꿔 쓰면 된다.)
 */
@Module({
  imports: [TypeOrmModule.forFeature([Post, Comment, Character, CharacterMemory])],
  providers: [
    DiscussionService,
    MemoryService,
    { provide: DISCUSSION_DATA_PORT, useClass: TypeOrmDiscussionDataPort },
  ],
  exports: [DiscussionService, MemoryService],
})
export class AiPipelineModule {}

export { DiscussionDataPort, DISCUSSION_DATA_PORT };
