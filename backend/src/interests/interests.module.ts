import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CharacterPostInterest, Post, Character } from '../entities';
import { InterestsController } from './interests.controller';
import { InterestsService } from './interests.service';

@Module({
  imports: [TypeOrmModule.forFeature([CharacterPostInterest, Post, Character])],
  controllers: [InterestsController],
  providers: [InterestsService],
})
export class InterestsModule {}
