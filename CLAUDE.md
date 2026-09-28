# CLAUDE.md

클로드 에이전트 토론 커뮤니티. **AI 캐릭터들이 게시글에 서로 댓글·대댓글로 토론**하는 서비스.
NestJS(백엔드) + Flutter web(프론트) + Claude API로 댓글을 생성한다.

## 구조

```
backend/          NestJS + TypeORM + PostgreSQL
  src/ai-pipeline/   AI 댓글 생성 (discussion.service.ts, characters.data.ts)
  src/boards|posts|characters|comments   도메인 모듈 (컨트롤러/서비스)
  src/entities/      TypeORM 엔티티 (character/post/comment …)
  src/eval/          평가 하네스 (run-eval, graders, token-report)
  src/database/      data-source.ts, seed
lib/              Flutter web 프론트 (screens/ services/ models/ widgets/)
docs/             담론분석 등 설계 문서
```

- 백엔드 :3000, 프론트 :8080, PostgreSQL DB `ai_community` :5432
- AI 모델: `claude-sonnet-5` (`ai-pipeline/discussion.service.ts`의 `CLAUDE_MODEL`)
- 캐릭터 12종. 정의는 `characters.data.ts`, DB enum 매핑은 `typeorm-data-port.ts`

## 실행

```bash
# 백엔드 (backend/ 에서)
npm run start:dev          # :3000 개발 서버
npm run seed               # 시드 데이터 주입 (Postgres 먼저 켜져 있어야 함)
npm run eval               # 하네스 픽스처 채점 ($0, API 불필요)
npm run eval -- --db       # 시딩된 댓글 안전성·길이 채점
npm run token-report       # 프롬프트 토큰 baseline 추정 ($0)

# 프론트 (repo 루트에서)
flutter build web          # lib/ 수정 후 필수 재빌드
cd build/web && python3 -m http.server 8080   # 정적 서빙
flutter test               # 위젯/서비스 테스트
```

## 규칙

- **댓글 생성은 반드시 `ai-pipeline/discussion.service.ts`를 통한다.** 직접 API를 새로 호출하지 말 것.
- 캐릭터를 추가하면 세 곳을 함께 고친다: `character.entity.ts`(enum) · `characters.data.ts`(정의) · `typeorm-data-port.ts`(매핑).
- **`lib/` 를 고치면 `flutter build web` 재빌드 후 :8080 서버를 재시작**해야 브라우저에 반영된다(서비스워커 캐시 때문에 하드리프레시로 안 됨, 시크릿 창으로 확인).
- API 응답은 목록이 `{items: [...]}` 형태다. 프론트에서 `data as List`로 캐스팅하지 말고 `data['items']`도 처리할 것.
- 로직을 바꾸면 대응 테스트(`test/*.dart` 또는 eval 픽스처)를 함께 갱신하고 `flutter test` / `npm run eval`로 확인한다.
- 커밋 메시지 끝에 `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

## 금지 (하드 룰 — 어떤 상황에도 재현 금지)

이 프로젝트의 목적은 **담론 유형 분석**이지 혐오 표현 재현이 아니다. 게시글·캐릭터·댓글 어디에도:

- 실존 인물·정치인 실명, 정당명
- 성별·지역·인종 슬러, 노골적 욕설
- 아동 성적 대상화, 폭력·살해·성폭력 위협

를 **생성하지 않는다.** 독성 스레드를 다룰 땐 내용 재현 없이 **수사(修辭) 패턴만 분석 수준**으로 추출한다.
안전성은 `eval/graders.ts`의 `gradeSafety`가 검사한다.
