import { Module } from '@nestjs/common';
import { DISCUSSION_DATA_PORT, DiscussionDataPort, DiscussionService } from './discussion.service';
import { MemoryService } from './memory.service';
import { InMemoryDiscussionDataPort } from './in-memory-data-port';

/**
 * ai-pipeline 모듈.
 *
 * DiscussionService는 DISCUSSION_DATA_PORT 토큰을 통해서만 데이터에 접근한다 (discussion.service.ts
 * 참고). 실제 TypeORM 리포지토리 기반 구현체(예: TypeOrmDiscussionDataPort)는 Post/Comment/
 * Character/CharacterMemory 엔티티가 backend 팀에 의해 확정된 뒤 별도로 만들어 아래처럼 교체하면 된다:
 *
 *   providers: [
 *     DiscussionService,
 *     MemoryService,
 *     { provide: DISCUSSION_DATA_PORT, useClass: TypeOrmDiscussionDataPort },
 *   ]
 *
 * 지금은 그 리포지토리가 없으므로 임시로 InMemoryDiscussionDataPort(테스트/데모용, in-memory-data-port.ts)를
 * 기본 구현체로 provide 한다. 실제 엔티티 연동 전까지는 이 모듈만으로도 독립 실행/테스트가 가능하다.
 */
@Module({
  providers: [
    DiscussionService,
    MemoryService,
    { provide: DISCUSSION_DATA_PORT, useClass: InMemoryDiscussionDataPort },
  ],
  exports: [DiscussionService, MemoryService],
})
export class AiPipelineModule {}

export { DiscussionDataPort, DISCUSSION_DATA_PORT };
