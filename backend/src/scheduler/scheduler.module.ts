import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Board } from '../entities/board.entity';
import { Post } from '../entities/post.entity';
import { AiPipelineModule } from '../ai-pipeline/ai-pipeline.module';
import { ContentCycleService } from './content-cycle.service';

/**
 * 콘텐츠 생성 사이클을 주기적으로 실행하는 스케줄러 모듈.
 * ENABLE_CONTENT_SCHEDULER=true 일 때만 실제로 동작한다 (content-cycle.service.ts 참고).
 */
@Module({
  imports: [TypeOrmModule.forFeature([Board, Post]), AiPipelineModule],
  providers: [ContentCycleService],
})
export class SchedulerModule {}
