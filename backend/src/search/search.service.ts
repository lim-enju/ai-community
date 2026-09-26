import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from '../entities';

@Injectable()
export class SearchService {
  constructor(@InjectRepository(Post) private readonly postRepo: Repository<Post>) {}

  async search(query?: string, tag?: string): Promise<Post[]> {
    const qb = this.postRepo.createQueryBuilder('post').leftJoinAndSelect('post.board', 'board');

    if (query) {
      qb.andWhere('post.sourceText ILIKE :query', { query: `%${query}%` });
    }

    if (tag) {
      qb.andWhere(':tag = ANY(post.tags)', { tag });
    }

    qb.orderBy('post.createdAt', 'DESC');

    return qb.getMany();
  }
}
