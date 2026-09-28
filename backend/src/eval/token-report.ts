/**
 * token-report.ts — 댓글 1개 생성 프롬프트의 토큰 baseline 측정기.
 *
 * API 키 없이($0) 대표 프롬프트를 조립해, 입력이 4덩어리(system/원문/스레드/요약)에
 * 각각 몇 토큰 들어가는지 "추정"한다. 최적화 전/후 비교의 기준선.
 *
 * 실행: npm run token-report
 */

import { buildCharacterSystemPrompt, getCharacterById } from '../ai-pipeline/characters.data';

/**
 * 토큰 추정(휴리스틱). 실제 토크나이저는 아니지만 전/후 비교엔 충분하다.
 * 한글/CJK는 토큰 밀도가 높아 글자당 ~1토큰, ASCII는 ~4글자당 1토큰으로 잡는다.
 * ponytail: 바이트 기반 근사. 정확한 값이 필요하면 messages.countTokens(유료 API)로 교체.
 */
export function estimateTokens(text: string): number {
  let cjk = 0;
  let other = 0;
  for (const ch of text) {
    if (/[　-鿿가-힣]/.test(ch)) cjk += 1;
    else other += 1;
  }
  return Math.round(cjk + other / 4);
}

// 대표 샘플: 게시글 + 6개짜리 스레드(우리 시딩 톤과 유사)
const SAMPLE_POST = {
  sourceText:
    'AI가 대신 써준 축하 메시지가 더 감동적이라는 시대, 진심의 가치는?\n' +
    '"어차피 마음은 진짜인데 문장만 다듬은 것"이라는 쪽과 "직접 쓴 서툰 말이 진짜"라는 쪽이 갈렸다.',
  tags: ['AI', '진심', '관계'],
};

const SAMPLE_THREAD = [
  '[R1 진영 프레이머] 결국 "기술 편"이냐 "사람 편"이냐로 갈리는 얘기지.',
  '[R1 장문 팩트 교정러] 진심은 문장 퀄리티랑 별개 축임. 마음이 진짜인지와 표현이 매끄러운지는 서로 다른 변수인데, 이 논쟁은 자꾸 둘을 하나로 묶어서 싸움. 도구가 표현을 도와도 진심의 유무는 안 바뀜.',
  '[R1 결과론 예언자] 이렇게 될 줄 알았지. 편지도 결국 대필 시대.',
  '[R1 진위 의심러] 더 감동적이었다는 그 반응, 진짜 측정한 거 맞음?',
  '[R1 당위 설교자] 서툴러도 직접 쓴 말에 정성이 있는 거죠..',
  '[R1 분위기 편승형] ㅇㅇ 손편지가 최고',
];

function main(): void {
  const character = getCharacterById('FACT_LECTURER');
  const system = buildCharacterSystemPrompt(character);
  const threadText = SAMPLE_THREAD.join('\n');
  const memory = '(이 캐릭터는 앞서 "진심과 표현은 별개 축"이라고 정정한 바 있음)';

  const userContent = `
[게시글 원문]
${SAMPLE_POST.sourceText}

[태그]
${SAMPLE_POST.tags.join(', ')}

[지금까지의 댓글 스레드]
${threadText}

[당신(${character.name})의 지금까지의 입장 요약]
${memory}
`.trim();

  const parts = [
    ['① system(페르소나)', system],
    ['② 게시글 원문', SAMPLE_POST.sourceText],
    ['③ 스레드 전체', threadText],
    ['④ 내 입장 요약', memory],
  ] as const;

  console.log('=== 댓글 1개 생성 입력 토큰 baseline (추정) ===\n');
  let sum = 0;
  for (const [label, text] of parts) {
    const t = estimateTokens(text);
    sum += t;
    console.log(`${label.padEnd(22)} ${String(t).padStart(5)} 토큰`);
  }
  const total = estimateTokens(system) + estimateTokens(userContent);
  console.log('─'.repeat(36));
  console.log(`${'입력 합계(system+user)'.padEnd(22)} ${String(total).padStart(5)} 토큰`);
  console.log(`\n참고: system이 전체의 ${Math.round((estimateTokens(system) / total) * 100)}% — 매 호출 반복되는 부분.`);
}

main();
