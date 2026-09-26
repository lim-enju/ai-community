import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post, Comment } from '../entities';

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
    @InjectRepository(Comment) private readonly commentRepo: Repository<Comment>,
  ) {}

  async findOne(postId: string): Promise<Post> {
    const post = await this.postRepo.findOne({ where: { id: postId }, relations: ['board'] });
    if (!post) {
      throw new NotFoundException(`Post not found: ${postId}`);
    }
    // Best-effort view count increment; read-only community, so this is the only mutation on read.
    await this.postRepo.increment({ id: postId }, 'viewCount', 1);
    post.viewCount += 1;
    return post;
  }

  async findComments(postId: string): Promise<Comment[]> {
    const post = await this.postRepo.findOne({ where: { id: postId } });
    if (!post) {
      throw new NotFoundException(`Post not found: ${postId}`);
    }
    return this.commentRepo.find({
      where: { postId },
      relations: ['character'],
      order: { roundNumber: 'ASC', createdAt: 'ASC' },
    });
  }
}
