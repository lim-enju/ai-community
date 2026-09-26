import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post, Comment } from '../entities';
import { InternalController } from './internal.controller';
import { InternalService } from './internal.service';

@Module({
  imports: [TypeOrmModule.forFeature([Post, Comment])],
  controllers: [InternalController],
  providers: [InternalService],
})
export class InternalModule {}
