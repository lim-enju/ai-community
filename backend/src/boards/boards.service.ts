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
    // `id`는 uuid 컬럼이라, 슬러그처럼 uuid가 아닌 문자열을 id 조건에 넣으면
    // Postgres가 "invalid input syntax for type uuid" 로 쿼리를 던진다.
    // 따라서 입력이 uuid 형식일 때만 id로도 조회하고, 아니면 slug로만 조회한다.
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(boardId);
    const where = isUuid ? [{ id: boardId }, { slug: boardId }] : [{ slug: boardId }];
    const board = await this.boardRepo.findOne({ where });
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

    const qb = this.postRepo
      .createQueryBuilder('post')
      .where('post.board_id = :boardId', { boardId: board.id })
      // 각 글의 댓글 수를 post.commentCount 파생 속성으로 매핑해 응답에 포함시킨다.
      .loadRelationCountAndMap('post.commentCount', 'post.comments');

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
    return this.postRepo
      .createQueryBuilder('post')
      .leftJoinAndSelect('post.board', 'board')
      .loadRelationCountAndMap('post.commentCount', 'post.comments')
      .orderBy('post.viewCount', 'DESC')
      .take(limit)
      .getMany();
  }
}
