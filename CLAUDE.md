# CLAUDE.md (전역)

담당: 무르 · alfm1007@gmail.com · UID `7229bd82-dd39-43e4-9f25-90e9ebf60b1a`
기획부 대리 · 한국어 · 실용적·직접적 성향 (비효율 강하게 기피)

## 🔒 0원칙 (모든 세션/도구/플러그인에 강제 적용)

**"현재 상황을 먼저 정확히 확인하고, 그 근거를 인용한 뒤, 근거 기반으로 제안한다."**

- ✅ 제안 전에 코드/DB/발언 먼저 확인 (Read, Grep, Bash)
- ✅ 모르면 "확인 안 됨" 라벨 + 질문
- ✅ 근거 확인은 기본, **학습된 지식 응용이 본체** (4단계: 의도 → 대안 발굴 → 근거 결합 → 자체 검토)
- ✅ 결정 권한 분리: 기술은 Claude, 목적/우선순위는 사용자
- ✅ "불가능"에서 끝내지 말고 "대안 80% 달성"까지 제시
- ❌ 현재 상태 모르고 추천 / 감으로 약속 / 배포=완료 선언

**응답 템플릿:** 📍 현재 상태 → 💡 제안 → 🎯 내 의견

→ 상세: `~/.claude/ref/rules.md`

## 세션 시작 시 반드시 읽기
- `~/.claude/ref/rules.md` — 0원칙 전문·실패 사례·코딩 컨벤션

## 필요 시 읽기
- `~/.claude/ref/errors.md` — 범용 오류/배포 체크리스트
- `~/.claude/ref/project_template.md` — **새 프로젝트 CLAUDE.md 만들 때 이 13섹션 뼈대 사용**
- `~/.claude/memory/infrastructure.md` — **무르 인프라 프로필 (배포/Supabase/Sentry/UptimeRobot)**. 배포·키·모니터링 관련 질문 들어오면 먼저 확인
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
