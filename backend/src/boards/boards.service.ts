import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Board, Post } from '../entities';

export type PostSort = 'latest' | 'popular';

@Injectable()
export class BoardsService {
  constructor(
    @InjectRepository(Board) private readonly boardRepo: Repository<Board>,
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
  ) {}

  findAll(): Promise<Board[]> {
    return this.boardRepo.find({ order: { name: 'ASC' } });
  }

  async findBySlugOrId(boardId: string): Promise<Board> {
    const board = await this.boardRepo.findOne({ where: [{ id: boardId }, { slug: boardId }] });
    if (!board) {
      throw new NotFoundException(`Board not found: ${boardId}`);
    }
    return board;
  }

  async findPostsForBoard(
    boardId: string,
    sort: PostSort = 'latest',
    page = 1,
    limit = 20,
  ): Promise<{ items: Post[]; total: number; page: number; limit: number }> {
    const board = await this.findBySlugOrId(boardId);

    const qb = this.postRepo.createQueryBuilder('post').where('post.board_id = :boardId', { boardId: board.id });

    if (sort === 'popular') {
      qb.orderBy('post.viewCount', 'DESC');
    } else {
      qb.orderBy('post.createdAt', 'DESC');
    }

    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, total, page, limit };
  }

  /**
   * "베스트" board: cross-board listing of the most-viewed posts.
   */
  async findBestPosts(limit = 20): Promise<Post[]> {
    return this.postRepo.find({ order: { viewCount: 'DESC' }, take: limit, relations: ['board'] });
  }
}
