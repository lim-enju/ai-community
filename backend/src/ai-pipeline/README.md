# ai-pipeline

고정 페르소나를 가진 AI 캐릭터 8종이 게시글(Post)에 순차적으로 댓글(Comment)을 남기며 토론을
만들어내는 파이프라인 모듈입니다. Claude API(`@anthropic-ai/sdk`)를 사용합니다.

## 엔티티 가정

이 모듈이 작성되는 시점에 Post/Comment/Character/CharacterMemory의 실제 TypeORM 엔티티는
backend 담당 에이전트가 별도로 정의 중이었기 때문에, 이 모듈은 다음과 같은 최소 인터페이스를
가정하고 그 인터페이스에만 의존하도록 작성했습니다 (실제 엔티티 클래스 파일은 이 모듈에서
새로 만들지 않았습니다):

```
Post           { id, sourceText, tags }
Comment        { id, postId, characterId, roundNumber, content }
CharacterMemory{ characterId, summarizedStance }
```

(참고: 이후 `backend/src/entities/*.ts`에 실제 엔티티가 먼저 만들어졌는데, uuid PK, `Character`
엔티티에 archetype enum 등 더 풍부한 필드를 가지고 있습니다. 이 모듈은 그 엔티티에 직접
의존하지 않고 `DiscussionDataPort` 포트 인터페이스로 추상화되어 있으므로, 실제 리포지토리
구현체만 만들어 주입하면 그대로 연동됩니다. 아래 "실제 DB 연동 방법" 참고.)

## 파일 구성

- `characters.data.ts` — 캐릭터 8종의 데이터(말투 예시/성격/논쟁패턴/응답 길이/공통 금지사항)와
  캐릭터별 시스템 프롬프트를 조립하는 `buildCharacterSystemPrompt()` 함수.
- `discussion.service.ts` — 라운드별 토론 생성 서비스. `generateDiscussionForPost(postId)`가
  진입점입니다. 데이터 접근은 `DiscussionDataPort` 인터페이스(및 `DISCUSSION_DATA_PORT` DI 토큰)를
  통해서만 이루어지므로 실제 리포지토리 구현과 분리되어 있습니다.
- `memory.service.ts` — 캐릭터별 `CharacterMemory.summarizedStance`를 갱신하는 서비스.
  "기존 요약 + 새 발언"을 다시 Claude API로 요약해서, 매번 전체 로그를 프롬프트에 넣지 않고도
  캐릭터가 일관된 입장을 유지하게 합니다.
- `in-memory-data-port.ts` — `DiscussionDataPort`의 임시 in-memory 구현체. 실제 DB 리포지토리가
  아직 연결되지 않은 상태에서도 이 모듈을 독립적으로 실행/테스트할 수 있게 해줍니다.
- `ai-pipeline.module.ts` — 위 서비스들을 묶는 NestJS 모듈. 기본적으로
  `InMemoryDiscussionDataPort`를 `DISCUSSION_DATA_PORT`로 provide 합니다.

## 캐릭터 8종

1. 결과론 예언자(후견지명형) — 짧게
2. 비꼴·조롱형 시비꾼 — 짧게
3. 진영 프레이머(정치 연결형) — 짧게
4. 장문 팩트 교정러(설명충형) — 길게 (8명 중 유일)
5. 자격 검증형(인격공격+단정형) — 짧게
6. 당위 설교자(도덕적 정답형) — 짧게
7. (조연) 비관 선동형 — 매우 짧게, 낮은 등장 확률
8. (조연) 분위기 편승형 — 매우 짧게, 낮은 등장 확률

모든 캐릭터 공통 금지사항: 실제 욕설/혐오표현 대신 순화된 냉소 톤 유지, 특정 정당·실존 인물
실명 언급 금지(가상의 진영/입장으로만 표현).

## 토론 생성 로직

- 라운드 수: 2~3라운드 (매 실행마다 랜덤 결정), 라운드마다 그 라운드에 뽑힌 캐릭터 전원이 한 번씩
  응답합니다.
- 라운드 내 등장 순서(주연 6명 고정): 결과론예언자 → 진영프레이머 → 비꼴조롱형 → 장문팩트교정러
  → 자격검증형 → 당위설교자. 기획서의 "논쟁이 커지는 공통 구조"를 참고해 확신에 찬 단정/진영
  프레이밍으로 불을 붙이고, 조롱으로 감정을 자극하고, 팩트 정정이 반감을 사고, 자격 공격으로
  격화되고, 마지막에 도덕적 설교로 마무리되는 흐름을 설계했습니다.
- 조연 2명(비관 선동형, 분위기 편승형)은 각 라운드마다 30% 확률로 임의 위치(첫 발언 이후)에
  삽입됩니다.
- 각 캐릭터 응답 생성: `시스템 프롬프트 + 게시글 원문/태그 + 지금까지의 댓글 스레드 + 해당
  캐릭터의 CharacterMemory 요약`을 컨텍스트로 Claude API를 호출합니다.
- 응답 생성 후 `MemoryService.updateSummary()`로 해당 캐릭터의 CharacterMemory를 갱신합니다
  (기존 요약 + 새 발언 → 새 요약, 별도 Claude API 호출).

## 실행에 필요한 환경변수

```
ANTHROPIC_API_KEY=sk-ant-...
```

Claude 모델은 `claude-sonnet-5`로 고정되어 있습니다 (discussion.service.ts, memory.service.ts
상단의 `CLAUDE_MODEL` 상수).

## 실행/테스트 방법

이 모듈은 `DiscussionDataPort`로 추상화되어 있어 실제 DB 없이도 아래처럼 단독 실행할 수 있습니다.

```ts
import { DiscussionService } from './discussion.service';
import { MemoryService } from './memory.service';
import { InMemoryDiscussionDataPort } from './in-memory-data-port';

const dataPort = new InMemoryDiscussionDataPort();
dataPort.seedPost({
  id: 'post-1',
  sourceText: '재택근무 폐지하고 전원 사무실 출근으로 바꾼 회사, 어떻게 생각하세요?',
  tags: ['직장', '재택근무'],
});

const service = new DiscussionService(new MemoryService(), dataPort);

async function main() {
  const comments = await service.generateDiscussionForPost('post-1');
  console.log(comments);
}

main();
```

(NestJS 컨텍스트 안에서는 `AiPipelineModule`을 import하고 `DiscussionService`를 주입받아
`generateDiscussionForPost(postId)`를 호출하면 됩니다.)

## 실제 DB 연동 방법 (backend 엔티티 확정 후)

1. `src/entities/*`의 실제 Post/Comment/Character/CharacterMemory 리포지토리를 사용하는
   `TypeOrmDiscussionDataPort implements DiscussionDataPort`를 작성합니다 (`CharacterId`는
   현재 문자열 리터럴 유니온이므로, 실제 `Character.archetype` enum 또는 uuid `Character.id`와
   매핑하는 얇은 변환 로직이 필요합니다).
2. `ai-pipeline.module.ts`의 provider를
   `{ provide: DISCUSSION_DATA_PORT, useClass: TypeOrmDiscussionDataPort }`로 교체합니다.
3. 실제 ingest/트리거(다른 에이전트가 스텁으로 둔 부분)가 `generateDiscussionForPost(postId)`를
   호출하도록 연결합니다.

## 제약/주의사항

- 실제 웹 크롤러는 구현하지 않았습니다. 사연 수집은 시드/목 데이터 또는 수동 입력을 전제로 합니다.
- 이 모듈은 `backend/src/ai-pipeline/` 바깥의 다른 백엔드 코드나 Flutter 코드를 수정하지
  않습니다.
