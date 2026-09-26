import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import { InternalApiKeyGuard } from '../common/internal-api-key.guard';
import { InternalService } from './internal.service';
import { IngestDto } from './dto/ingest.dto';

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
}
