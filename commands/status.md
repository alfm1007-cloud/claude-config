---
description: 멀티 프로젝트 상태 1회 조회 (성내동/swresort/agoda-auto + git + sw.js + 외부 헬스체크)
---

# 멀티 프로젝트 상태 리포트

세션 시작 시 또는 상황 파악 필요 시 한 번에 모든 프로젝트 현황 확인.

## 자동 실행 절차 (Bash 병렬)

각 프로젝트(`~/Desktop/Claude/성내동`, `~/Desktop/Claude/swresort`, `~/Desktop/Claude/agoda-auto`)에 대해:

1. **Git 상태**
   - `git status --short` (수정 파일 카운트)
   - `git log -1 --pretty="%h %s (%ar)"`
   - `git rev-list --count HEAD..@{u} 2>/dev/null` (origin 격차)

2. **Service Worker 버전**
   - `grep "CACHE_NAME" public/sw.js` 또는 동등 파일

3. **DB 마이그레이션 — 가장 최신 SQL 파일**
   - `ls -t supabase_migration_v*.sql 2>/dev/null | head -1`

## 출력 형식 (간결 표)

| 프로젝트 | 마지막 커밋 | 미커밋 | origin 격차 | sw 버전 | 최신 SQL |
|---------|-----------|--------|------------|---------|---------|
| 성내동 | b7bf2d7 (1h ago) | 0 | 0 | snd-v73 | v8 |
| swresort | ... | ... | ... | swr-vXX | ... |
| agoda-auto | ... | ... | ... | - | - |

## 알림
- ⚠️ origin 격차 1+ → "다른 환경 작업 있음. git pull 권장"
- 🔴 미커밋 5+ → "커밋되지 않은 변경 다수"
- ❓ sw 버전 ≠ 최근 커밋 vNN → "sw.js bump 누락 가능"

## 사용 예
- `/status` → 한 번에 전체 현황 출력
- 세션 시작 시 자동 (SessionStart hook 보강 가능)
