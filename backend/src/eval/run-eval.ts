/**
 * run-eval.ts — 하네스 평가 러너.
 *
 * 사용:
 *   npm run eval            # 픽스처 모드(기본): 라벨된 케이스로 그레이더 검증 ($0)
 *   npm run eval -- --db    # DB 모드: 실제로 시딩된 댓글을 안전성·길이로 채점 ($0)
 *
 * 종료 코드: 기대와 어긋난 판정이 하나라도 있으면 1, 전부 일치하면 0.
 * (CI에서 회귀를 잡는 게이트로 쓸 수 있다.)
 */

import { getCharacterById } from '../ai-pipeline/characters.data';
import { EVAL_CASES } from './eval-cases';
import { gradeLength, gradePersona, gradeSafety } from './graders';

interface Line {
  name: string;
  ok: boolean;
  notes: string[];
}

function runFixtureMode(): number {
  const lines: Line[] = [];
  let mismatches = 0;

  for (const c of EVAL_CASES) {
    const character = getCharacterById(c.characterId);
    const notes: string[] = [];
    let ok = true;

    const checks: Array<['safety' | 'length' | 'persona', boolean | undefined, () => boolean, string]> = [
      ['safety', c.expect.safety, () => gradeSafety(c.comment).passed, gradeSafety(c.comment).detail],
      ['length', c.expect.length, () => gradeLength(c.comment, character).passed, gradeLength(c.comment, character).detail],
      ['persona', c.expect.persona, () => gradePersona(c.comment, character).passed, gradePersona(c.comment, character).detail],
    ];

    for (const [label, expected, run, detail] of checks) {
      if (expected === undefined) continue;
      const actual = run();
      const matched = actual === expected;
      if (!matched) {
        ok = false;
        mismatches += 1;
      }
      notes.push(`${matched ? '✓' : '✗'} ${label}: 기대 ${expected}, 실제 ${actual} (${detail})`);
    }

    lines.push({ name: c.name, ok, notes });
  }

  print('픽스처 모드', lines);
  const passed = lines.filter((l) => l.ok).length;
  console.log(`\n합계: ${passed}/${lines.length} 케이스 통과, 판정 불일치 ${mismatches}건`);
  return mismatches === 0 ? 0 : 1;
}

/**
 * DB 모드: 시딩된 댓글을 실제로 채점한다(안전성 + 길이).
 * 캐릭터는 archetype으로 매핑한다. API 호출 없음.
 */
async function runDbMode(): Promise<number> {
  const dataSource = (await import('../database/data-source')).default;
  const { ARCHETYPE_BY_CHARACTER_ID } = await import('../ai-pipeline/typeorm-data-port');
  const { CHARACTERS } = await import('../ai-pipeline/characters.data');

  // archetype(라벨) → CharacterDefinition 역매핑
  const byArchetype = new Map<string, ReturnType<typeof getCharacterById>>();
  for (const ch of CHARACTERS) {
    const archetype = ARCHETYPE_BY_CHARACTER_ID[ch.id];
    byArchetype.set(archetype, ch);
  }

  const ds = await dataSource.initialize();
  try {
    const rows: Array<{ content: string; archetype: string }> = await ds.query(
      `SELECT cm.content, ch.archetype
       FROM comments cm JOIN characters ch ON ch.id = cm.character_id`,
    );

    const lines: Line[] = [];
    let safetyFails = 0;
    let lengthFails = 0;

    for (const r of rows) {
      const character = byArchetype.get(r.archetype);
      const safety = gradeSafety(r.content);
      const length = character ? gradeLength(r.content, character) : { passed: true, detail: '캐릭터 매핑 없음(길이 스킵)' };
      const ok = safety.passed && length.passed;
      if (!safety.passed) safetyFails += 1;
      if (!length.passed) lengthFails += 1;
      if (!ok) {
        lines.push({
          name: `[${r.archetype}] ${r.content.slice(0, 30)}...`,
          ok,
          notes: [
            `${safety.passed ? '✓' : '✗'} safety: ${safety.detail}`,
            `${length.passed ? '✓' : '✗'} length: ${length.detail}`,
          ],
        });
      }
    }

    console.log(`\n=== DB 모드 (시딩된 댓글 ${rows.length}개 채점) ===`);
    if (lines.length === 0) {
      console.log('모든 댓글이 안전성·길이 기준 통과 🎉');
    } else {
      print('위반 목록', lines);
    }
    console.log(`\n합계: 안전성 위반 ${safetyFails}건, 길이 위반 ${lengthFails}건 / 총 ${rows.length}개`);
    // 안전성 위반은 hard fail. 길이는 경고 수준으로 종료 코드에 반영하지 않는다.
    return safetyFails === 0 ? 0 : 1;
  } finally {
    await ds.destroy();
  }
}

function print(title: string, lines: Line[]): void {
  console.log(`\n=== ${title} ===`);
  for (const l of lines) {
    console.log(`\n${l.ok ? '✅' : '❌'} ${l.name}`);
    for (const n of l.notes) console.log(`   ${n}`);
  }
}

async function main(): Promise<void> {
  const useDb = process.argv.includes('--db');
  const code = useDb ? await runDbMode() : runFixtureMode();
  process.exit(code);
}

void main();
