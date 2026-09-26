import { Injectable } from '@nestjs/common';
import Anthropic from '@anthropic-ai/sdk';
import { CharacterId } from './characters.data';

/**
 * 엔티티 가정 (실제 클래스는 다른 에이전트가 정의 중이므로 여기서는 인터페이스로만 취급):
 *   CharacterMemory { characterId, summarizedStance }
 */
export interface CharacterMemoryLike {
  characterId: CharacterId;
  summarizedStance: string;
}

const CLAUDE_MODEL = 'claude-sonnet-5';

/**
 * CharacterMemory 갱신 서비스.
 *
 * 매 라운드 캐릭터가 새 댓글을 남길 때마다, "기존 요약 + 이번에 새로 남긴 발언"을
 * 다시 짧게 요약해서 CharacterMemory.summarizedStance 를 갱신한다.
 * 이렇게 하면 매번 전체 댓글 로그를 프롬프트에 다시 넣지 않고도
 * 캐릭터가 일관된 입장을 유지할 수 있다.
 */
@Injectable()
export class MemoryService {
  private readonly anthropic: Anthropic;

  constructor() {
    this.anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });
  }

  /**
   * 기존 요약(existingSummary)과 이번 라운드의 새 발언(newStatement)을 합쳐
   * 새로운 요약을 생성한다. existingSummary가 비어있으면 첫 요약을 만든다.
   */
  async updateSummary(params: {
    characterName: string;
    existingSummary: string;
    newStatement: string;
    postSourceText: string;
  }): Promise<string> {
    const { characterName, existingSummary, newStatement, postSourceText } = params;

    const systemPrompt = `
당신은 토론 댓글 캐릭터 "${characterName}"의 입장을 추적하는 요약기입니다.
"기존 입장 요약"과 "이번에 새로 남긴 댓글"을 바탕으로, 이 캐릭터가 이 게시글에 대해
지금까지 취해온 입장/태도/주로 쓴 논리를 3문장 이내의 새 요약으로 압축하세요.
전체 댓글 로그를 나열하지 말고, 다음 응답 생성 시 참고할 "입장 요약"만 간결하게 출력하세요.
메타 설명 없이 요약 본문만 출력하세요.
`.trim();

    const userContent = `
[게시글 원문 요약 참고용]
${postSourceText}

[기존 입장 요약]
${existingSummary || '(아직 없음 - 첫 발언)'}

[이번에 새로 남긴 댓글]
${newStatement}
`.trim();

    const response = await this.anthropic.messages.create({
      model: CLAUDE_MODEL,
      max_tokens: 300,
      system: systemPrompt,
      messages: [{ role: 'user', content: userContent }],
    });

    const textBlock = response.content.find((block) => block.type === 'text');
    return textBlock && 'text' in textBlock ? textBlock.text.trim() : existingSummary;
  }
}
