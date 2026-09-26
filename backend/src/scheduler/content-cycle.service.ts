import { Injectable, Logger, OnApplicationBootstrap, OnModuleDestroy } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Board } from '../entities/board.entity';
import { Post } from '../entities/post.entity';
import { DiscussionService } from '../ai-pipeline/discussion.service';
import { SAMPLE_STORIES } from './sample-stories';

const DEFAULT_INTERVAL_MS = 4 * 60 * 60 * 1000; // 4시간 → 하루 약 6회

/**
 * 콘텐츠 생성 사이클 스케줄러.
 *
 * 기획서의 "수집 → 선별 → 게시 → 캐릭터 토론 생성" 한 사이클을 주기적으로 실행한다.
 * 크롤러 대신 SAMPLE_STORIES 풀에서 아직 게시되지 않은 사연 하나를 골라 게시(ingest)하고,
 * 댓글이 없는 게시글 하나에 대해 DiscussionService로 캐릭터 토론을 생성한다.
 *
 * 안전장치: ENABLE_CONTENT_SCHEDULER=true 일 때만 동작한다. 이 사이클은 Claude API를
 * 다수 호출(게시글당 수십 콜)하므로, 기본값(비활성)에서는 실수로 비용이 발생하지 않는다.
 */
@Injectable()
export class ContentCycleService implements OnApplicationBootstrap, OnModuleDestroy {
  private readonly logger = new Logger(ContentCycleService.name);
  private timer?: NodeJS.Timeout;
  private running = false;

  constructor(
    @InjectRepository(Board) private readonly boardRepo: Repository<Board>,
    @InjectRepository(Post) private readonly postRepo: Repository<Post>,
    private readonly discussionService: DiscussionService,
  ) {}

  onApplicationBootstrap(): void {
    if (process.env.ENABLE_CONTENT_SCHEDULER !== 'true') {
      this.logger.log(
        '콘텐츠 스케줄러 비활성 상태입니다. 자동 게시/토론 생성을 켜려면 ENABLE_CONTENT_SCHEDULER=true 로 실행하세요.',
      );
      return;
    }

    const intervalMs = Number(process.env.CONTENT_CYCLE_INTERVAL_MS) || DEFAULT_INTERVAL_MS;
    this.logger.log(`콘텐츠 스케줄러 활성. 사이클 주기 ${intervalMs}ms (약 ${(intervalMs / 3600000).toFixed(1)}시간).`);

    // 부팅 직후 한 번, 이후 주기마다 실행
    void this.runCycleSafely();
    this.timer = setInterval(() => void this.runCycleSafely(), intervalMs);
  }

  onModuleDestroy(): void {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  /** 한 사이클을 실행하되, 이전 사이클이 아직 돌고 있으면 건너뛰고 예외는 삼킨다. */
  private async runCycleSafely(): Promise<void> {
    if (this.running) {
      this.logger.warn('이전 사이클이 아직 진행 중이라 이번 주기는 건너뜁니다.');
      return;
    }
    this.running = true;
    try {
      await this.runCycle();
    } catch (err) {
      this.logger.error(`사이클 실행 중 오류: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      this.running = false;
    }
  }

  async runCycle(): Promise<void> {
    await this.ingestNextSampleStory();
    await this.generateForOnePendingPost();
  }

  /** 아직 게시되지 않은 샘플 사연 하나를 골라 Post로 저장한다. */
  private async ingestNextSampleStory(): Promise<void> {
    for (const story of SAMPLE_STORIES) {
      const already = await this.postRepo.findOne({ where: { sourceText: story.sourceText } });
      if (already) {
        continue;
      }
      const board = await this.boardRepo.findOne({ where: { slug: story.boardSlug } });
      if (!board) {
        this.logger.warn(`게시판(slug=${story.boardSlug})을 찾을 수 없어 사연을 건너뜁니다. 시드를 확인하세요.`);
        continue;
      }
      const post = await this.postRepo.save(
        this.postRepo.create({
          boardId: board.id,
          sourceText: story.sourceText,
          sourceUrl: story.sourceUrl ?? null,
          tags: story.tags,
        }),
      );
      this.logger.log(`새 게시글 등록: ${post.id} (board=${story.boardSlug})`);
      return;
    }
    this.logger.log('게시할 새 샘플 사연이 없습니다. (풀 소진)');
  }

  /** 아직 댓글이 하나도 없는 게시글 하나를 골라 캐릭터 토론을 생성한다. */
  private async generateForOnePendingPost(): Promise<void> {
    const pending = await this.postRepo
      .createQueryBuilder('post')
      .leftJoin('post.comments', 'comment')
      .where('comment.id IS NULL')
      .orderBy('post.created_at', 'ASC')
      .getOne();

    if (!pending) {
      this.logger.log('토론을 생성할 대상(댓글 없는 게시글)이 없습니다.');
      return;
    }

    this.logger.log(`게시글 ${pending.id}에 대해 캐릭터 토론 생성 시작...`);
    const comments = await this.discussionService.generateDiscussionForPost(pending.id);
    this.logger.log(`게시글 ${pending.id} 토론 생성 완료: 댓글 ${comments.length}개.`);
  }
}
