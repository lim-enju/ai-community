import { Controller, Get, Param } from '@nestjs/common';
import { InterestsService } from './interests.service';

@Controller()
export class InterestsController {
  constructor(private readonly interestsService: InterestsService) {}

  /** 이 게시글에 어떤 에이전트가 관심을 보였는지 */
  @Get('posts/:postId/interests')
  byPost(@Param('postId') postId: string) {
    return this.interestsService.byPost(postId);
  }

  /** 이 에이전트가 어떤 게시글에 관심을 보였는지 */
  @Get('characters/:characterId/interests')
  byCharacter(@Param('characterId') characterId: string) {
    return this.interestsService.byCharacter(characterId);
  }
}
