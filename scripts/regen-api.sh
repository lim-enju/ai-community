#!/usr/bin/env bash
#
# regen-api.sh — 백엔드 OpenAPI 스펙에서 Flutter 타입드 클라이언트를 재생성한다.
#
# 백엔드 API(컨트롤러·DTO·엔티티)를 바꾼 뒤 이 스크립트 하나만 돌리면
# ① 스펙 추출 → ② Dart 모델·클라이언트 생성 → ③ 직렬화 코드 생성이 순서대로 실행된다.
#
# 사전조건: PostgreSQL 이 켜져 있어야 한다(스펙 추출 시 앱이 부팅되며 DB에 연결).
#   brew services start postgresql@16
#
# 사용: bash scripts/regen-api.sh   (repo 루트 기준)
set -euo pipefail
cd "$(dirname "$0")/.."

echo "① OpenAPI 스펙 추출 (backend/openapi.json)..."
( cd backend && npm run --silent build && npm run --silent openapi:export )

echo "② Dart 모델·클라이언트 생성 (lib/api)..."
dart run swagger_parser

echo "③ 직렬화 코드 생성 (build_runner)..."
dart run build_runner build

echo "✅ API 재생성 완료 → lib/api"
