---
name: regen-api
description: 백엔드 OpenAPI 스펙에서 Flutter 타입드 API 클라이언트(lib/api)를 재생성한다. 백엔드 컨트롤러·DTO·엔티티를 바꾼 뒤 프론트 모델/클라이언트를 맞출 때 사용. "API 재생성", "openapi 다시 뽑아줘", "swagger 코드 생성" 같은 요청에 해당.
---

# API 클라이언트 재생성

백엔드(NestJS)의 OpenAPI 스펙에서 Flutter용 모델과 retrofit 클라이언트(`lib/api`)를 자동생성하는 3단계 파이프라인을 실행한다.

## 실행

```bash
bash scripts/regen-api.sh
```

이 스크립트가 순서대로 처리한다:
1. `backend` 빌드 후 `OPENAPI_EXPORT=1`로 `backend/openapi.json` 추출
2. `dart run swagger_parser` — 스펙 → `lib/api` 모델·클라이언트 생성
3. `dart run build_runner build` — json_serializable/retrofit 직렬화 코드 생성

## 사전조건

- **PostgreSQL이 켜져 있어야 한다** (①에서 앱이 부팅되며 DB에 연결). 꺼져 있으면 `brew services start postgresql@16`.

## 주의

- `lib/api`는 전부 생성물이다. 손으로 고치지 말고 스펙(엔티티/DTO)을 고친 뒤 이 스킬을 다시 돌린다.
- 생성 모델이 실제 응답과 어긋나면(엔티티 관계가 required로 잡히는 등), 응답에 없는 관계 필드는 엔티티에서 `@ApiHideProperty()`로 스펙에서 제외한 뒤 재생성한다.
- 재생성 후 `flutter analyze`와 `flutter test`로 확인한다.
