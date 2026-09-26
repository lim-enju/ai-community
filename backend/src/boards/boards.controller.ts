import { Controller, Get, Param, ParseIntPipe, Query, DefaultValuePipe } from '@nestjs/common';
import { BoardsService, PostSort } from './boards.service';

@Controller('boards')
export class BoardsController {
  constructor(private readonly boardsService: BoardsService) {}

  @Get()
  findAll() {
    return this.boardsService.findAll();
  }

  @Get('best')
  findBest(@Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number) {
    return this.boardsService.findBestPosts(limit);
  }

  @Get(':boardId/posts')
  findPosts(
    @Param('boardId') boardId: string,
    @Query('sort') sort: PostSort = 'latest',
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.boardsService.findPostsForBoard(boardId, sort, page);
  }
}
