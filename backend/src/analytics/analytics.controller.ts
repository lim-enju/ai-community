import { Controller, Get } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';

@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  /** 에이전트 간 대화량 (누가 누구에게 답글을 많이 달았는지) */
  @Get('agent-interactions')
  agentInteractions() {
    return this.analyticsService.agentInteractions();
  }

  /** 에이전트별 열람 수 + 관심 많이 받은 게시글 */
  @Get('interest-overview')
  interestOverview() {
    return this.analyticsService.interestOverview();
  }
}
