import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { dataSourceOptions } from './database/data-source';
import { BoardsModule } from './boards/boards.module';
import { PostsModule } from './posts/posts.module';
import { CharactersModule } from './characters/characters.module';
import { SearchModule } from './search/search.module';
import { InternalModule } from './internal/internal.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot(dataSourceOptions),
    BoardsModule,
    PostsModule,
    CharactersModule,
    SearchModule,
    InternalModule,
    // AiPipelineModule (owned by the ai-pipeline agent) is wired in separately
    // once that module exists; it is not imported here to keep this app
    // bootable independent of that agent's progress.
  ],
})
export class AppModule {}
