import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import { InternalApiKeyGuard } from '../common/internal-api-key.guard';
import { InternalService } from './internal.service';
import { IngestDto } from './dto/ingest.dto';
import { AgentViewDto } from './dto/agent-view.dto';

@Controller('internal')
@UseGuards(InternalApiKeyGuard)
export class InternalController {
  constructor(private readonly internalService: InternalService) {}

  @Post('ingest')
  ingest(@Body() dto: IngestDto) {
    return this.internalService.ingest(dto);
  }

  @Post('posts/:postId/generate-comments')
  generateComments(@Param('postId') postId: string) {
    return this.internalService.generateComments(postId);
  }

  /** 에이전트가 게시글을 조회했음을 기록 (조회수 +1, 관심 기록). 댓글 작성과는 별개. */
  @Post('posts/:postId/view')
  recordView(@Param('postId') postId: string, @Body() dto: AgentViewDto) {
    return this.internalService.recordAgentView(postId, dto.characterId, dto.note);
  }
}
