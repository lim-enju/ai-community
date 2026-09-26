import { Inject, Injectable, Logger } from '@nestjs/common';
import Anthropic from '@anthropic-ai/sdk';
import {
  CHARACTERS,
  CharacterDefinition,
  CharacterId,
  MAIN_CHARACTER_ORDER,
  SUPPORTING_CHARACTER_IDS,
  buildCharacterSystemPrompt,
  getCharacterById,
} from './characters.data';
import { CharacterMemoryLike, MemoryService } from './memory.service';

/**
 * 엔티티 가정 (실제 TypeORM 엔티티는 다른 에이전트가 정의 중이므로, 여기서는 인터페이스로만 취급):
 *   Post { id, sourceText, tags }
 *   Comment { id, postId, characterId, roundNumber, content }
 *   CharacterMemory { characterId, summarizedStance }
 */
export interface PostLike {
  id: string;
  sourceText: string;
  tags: string[];
}

export interface CommentLike {
  id?: string;
  postId: string;
  characterId: CharacterId;
  roundNumber: number;
  content: string;
}

const CLAUDE_MODEL = 'claude-sonnet-5';
const MIN_ROUNDS = 2;
const MAX_ROUNDS = 3;

/** 조연 캐릭터가 한 라운드에 등장할 확률 (기획서: "낮은 확률로 랜덤 삽입") */
const SUPPORTING_APPEARANCE_PROBABILITY = 0.3;

/**
 * 데이터 접근 레이어를 추상화한 포트.
 * 실제 리포지토리(TypeORM Repository 등)는 다른 에이전트의 엔티티 확정 후 구현체를 주입한다.
 * 이 서비스는 이 인터페이스에만 의존하므로 엔티티 스키마가 바뀌어도 discussion.service.ts는
 * 최소한의 수정만 필요하다.
 */
export interface DiscussionDataPort {
  getPost(postId: string): Promise<PostLike>;
  getExistingComments(postId: string): Promise<CommentLike[]>;
  saveComment(comment: CommentLike): Promise<CommentLike>;
  getMemory(characterId: CharacterId): Promise<CharacterMemoryLike | null>;
  saveMemory(memory: CharacterMemoryLike): Promise<void>;
}

/**
 * DI 토큰. TypeScript 인터페이스는 런타임에 사라지므로, Nest가 DiscussionDataPort 구현체를
 * 주입할 수 있도록 별도 토큰을 둔다. 실제 구현체는 이 토큰으로 provide 해야 한다:
 *   { provide: DISCUSSION_DATA_PORT, useClass: TypeOrmDiscussionDataPort }
 */
export const DISCUSSION_DATA_PORT = 'DISCUSSION_DATA_PORT';

/**
 * 토론 생성 서비스.
 *
 * 라운드 진행 순서 (기획서의 "논쟁이 커지는 공통 구조" 참고):
 *   1. 결과론 예언자 / 진영 프레이머 - 초반에 확신에 찬 단정 또는 진영 프레임을 던져 불씨를 만든다.
 *   2. 비꼴·조롱형 시비꾼 - 감정적으로 분위기를 자극해 반박을 유도한다.
 *   3. 장문 팩트 교정러 - 근거를 들어 정정하지만 가르치는 톤 때문에 반감을 산다.
 *   4. 자격 검증형 - 논지 대신 상대의 자격/의도를 공격하며 논쟁을 격화시킨다.
 *   5. 당위 설교자 - 도덕적 명제로 마무리하듯 끼어들며 은근히 깎아내린다.
 * 조연 2명(비관 선동형, 분위기 편승형)은 각 라운드마다 낮은 확률로 임의 위치에 삽입된다.
 *
 * 총 2~3라운드 진행, 라운드마다 그 라운드에 뽑힌 캐릭터 전원이 한 번씩 응답한다.
 */
@Injectable()
export class DiscussionService {
  private readonly logger = new Logger(DiscussionService.name);
  private readonly anthropic: Anthropic;

  constructor(
    private readonly memoryService: MemoryService,
    @Inject(DISCUSSION_DATA_PORT) private readonly dataPort: DiscussionDataPort,
  ) {
    this.anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });
  }

  /**
   * 주어진 postId에 대해 2~3라운드의 캐릭터 댓글 토론을 생성하고 저장한다.
   */
  async generateDiscussionForPost(postId: string): Promise<CommentLike[]> {
    const post = await this.dataPort.getPost(postId);
    const totalRounds = MIN_ROUNDS + (Math.random() < 0.5 ? 0 : 1); // 2 or 3
    const generatedComments: CommentLike[] = [...(await this.dataPort.getExistingComments(postId))];

    for (let round = 1; round <= totalRounds; round++) {
      const order = this.buildRoundOrder();

      for (const characterId of order) {
        const character = getCharacterById(characterId);
        const comment = await this.generateSingleCommentAndUpdateMemory(
          post,
          character,
          round,
          generatedComments,
        );
        generatedComments.push(comment);
      }
    }

    return generatedComments;
  }

  /** 라운드 내 캐릭터 등장 순서를 만든다: 주연 6명 고정 순서 + 조연 2명 낮은 확률 랜덤 삽입 */
  private buildRoundOrder(): CharacterId[] {
    const order: CharacterId[] = [...MAIN_CHARACTER_ORDER];

    for (const supportingId of SUPPORTING_CHARACTER_IDS) {
      if (Math.random() < SUPPORTING_APPEARANCE_PROBABILITY) {
        const insertPosition = 1 + Math.floor(Math.random() * order.length); // 첫 발언(불씨) 이후 임의 위치
        order.splice(insertPosition, 0, supportingId);
      }
    }

    return order;
  }

  private async generateSingleCommentAndUpdateMemory(
    post: PostLike,
    character: CharacterDefinition,
    roundNumber: number,
    threadSoFar: CommentLike[],
  ): Promise<CommentLike> {
    const memory = await this.dataPort.getMemory(character.id);
    const existingSummary = memory?.summarizedStance ?? '';

    const content = await this.callClaudeForComment(post, character, threadSoFar, existingSummary);

    const savedComment = await this.dataPort.saveComment({
      postId: post.id,
      characterId: character.id,
      roundNumber,
      content,
    });

    const updatedSummary = await this.memoryService.updateSummary({
      characterName: character.name,
      existingSummary,
      newStatement: content,
      postSourceText: post.sourceText,
    });

    await this.dataPort.saveMemory({
      characterId: character.id,
      summarizedStance: updatedSummary,
    });

    this.logger.debug(`[round ${roundNumber}] ${character.name}: ${content}`);

    return savedComment;
  }

  private async callClaudeForComment(
    post: PostLike,
    character: CharacterDefinition,
    threadSoFar: CommentLike[],
    memorySummary: string,
  ): Promise<string> {
    const systemPrompt = buildCharacterSystemPrompt(character);
    const threadText = this.renderThreadForPrompt(threadSoFar);

    const userContent = `
[게시글 원문]
${post.sourceText}

[태그]
${post.tags.join(', ')}

[지금까지의 댓글 스레드]
${threadText || '(아직 댓글 없음 - 이 댓글이 첫 댓글)'}

[당신(${character.name})의 지금까지의 입장 요약]
${memorySummary || '(아직 없음 - 이번이 첫 발언)'}

위 내용을 참고하여 "${character.name}" 페르소나에 맞는 댓글을 한 개만 작성하세요.
`.trim();

    const response = await this.anthropic.messages.create({
      model: CLAUDE_MODEL,
      max_tokens: character.lengthGuide === 'long' ? 500 : 150,
      system: systemPrompt,
      messages: [{ role: 'user', content: userContent }],
    });

    const textBlock = response.content.find((block) => block.type === 'text');
    return textBlock && 'text' in textBlock ? textBlock.text.trim() : '';
  }

  private renderThreadForPrompt(threadSoFar: CommentLike[]): string {
    return threadSoFar
      .map((c) => {
        const name = CHARACTERS.find((ch) => ch.id === c.characterId)?.name ?? c.characterId;
        return `[R${c.roundNumber} ${name}] ${c.content}`;
      })
      .join('\n');
  }
}
