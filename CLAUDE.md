# CLAUDE.md (전역)

담당: 무르 · alfm1007@gmail.com · UID `7229bd82-dd39-43e4-9f25-90e9ebf60b1a`
기획부 대리 · 한국어 · 실용적·직접적 성향 (비효율 강하게 기피)

## 세션 시작 시 반드시 읽기
- `~/.claude/ref/rules.md` — 0원칙·작업 프로세스·코딩 컨벤션

## 필요 시 읽기
- `~/.claude/ref/errors.md` — 범용 오류/배포 체크리스트
- `~/.claude/memory/user_identity.md` · `dev_context.md` · `planning_context.md` · `design_context.md`
- 프로젝트 작업 시 해당 폴더의 `CLAUDE.md` 자동 로드 (swresort / agoda-auto / 성내동 등)

## 파일 저장 (바탕화면 루트 직접 생성 금지)
| 용도 | 경로 |
|------|------|
| 신규 프로젝트 | `Desktop\Claude\[프로젝트명]\` |
| swresort | `Desktop\Claude\swresort\` |
| agoda-auto | `Desktop\Claude\agoda-auto\` |
| 성내동 | `Desktop\Claude\성내동\` |
| HTML 미리보기 | `Desktop\Claude\미리보기\` |
| 보고서/문서 | `Desktop\Claude\문서\` |

## 동기화
- 세션 종료 → Stop hook이 자동 `git push`
- 세션 시작 → SessionStart hook이 자동 `git pull --ff-only`
- 수동 동기화: `/sync`
- 상세 시나리오: `~/.claude/README.md`
