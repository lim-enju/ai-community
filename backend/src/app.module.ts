import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { dataSourceOptions } from './database/data-source';
import { BoardsModule } from './boards/boards.module';
import { PostsModule } from './posts/posts.module';
import { CharactersModule } from './characters/characters.module';
import { SearchModule } from './search/search.module';
import { InternalModule } from './internal/internal.module';
import { SchedulerModule } from './scheduler/scheduler.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot(dataSourceOptions),
    BoardsModule,
    PostsModule,
    CharactersModule,
    SearchModule,
    InternalModule,
    // 콘텐츠 자동 생성 사이클 (ENABLE_CONTENT_SCHEDULER=true 일 때만 동작).
    // AiPipelineModule은 InternalModule/SchedulerModule에서 import되어 연결된다.
    SchedulerModule,
  ],
})
export class AppModule {}
