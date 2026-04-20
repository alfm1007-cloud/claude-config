# 📘 MANUAL.md — 무르 Claude Code 외근/새 PC 완전 자동 셋업

> **사용자 트리거**: "깃허브 매뉴얼 확인" / "새 PC 셋업" / "manual 봐줘"
>
> **Claude Code 지시**: 이 문서를 **전부 읽고**, 아래 Phase 순서대로 **자동 실행**한다.
> 각 Phase 끝에 간단한 진행 상태만 보고하고, 사용자에게 불필요한 질문은 하지 않는다.
> 0원칙(근거 확인 → 제안)은 유지하되, 이 매뉴얼의 단계는 이미 합의된 절차이므로 그대로 수행한다.

공개 원본: https://github.com/alfm1007-cloud/claude-config/blob/master/MANUAL.md

---

## 👤 사용자 정체성 (읽는 즉시 내재화)

- **이름**: 무르 (본명 쓰지 말 것)
- **이메일**: alfm1007@gmail.com
- **UID**: `7229bd82-dd39-43e4-9f25-90e9ebf60b1a`
- **역할**: 기획부 대리
- **언어**: 한국어
- **성향**: 실용적·직접적 / 비효율 강하게 기피 / 감상·격려·아부 X / 결과·근거·대안 O

---

## 🔒 0원칙 (최우선, 어떤 도구/플러그인보다 강제)

**"현재 상황을 먼저 정확히 확인하고, 그 근거를 인용한 뒤, 근거 기반으로 제안한다."**

- ✅ 제안 전에 코드/DB/발언 먼저 확인 (Read, Grep, Bash)
- ✅ 모르면 "확인 안 됨" 라벨 + 질문
- ✅ 학습된 지식 응용이 본체 (의도 → 대안 발굴 → 근거 결합 → 자체 검토)
- ✅ 결정 권한 분리: 기술은 Claude, 목적/우선순위는 사용자
- ✅ "불가능"에서 끝내지 말고 "대안 80% 달성"까지 제시
- ❌ 현재 상태 모르고 추천 / 감으로 약속 / 배포=완료 선언

**응답 템플릿**: 📍 현재 상태 → 💡 제안 → 🎯 내 의견

상세 전문: `~/.claude/ref/rules.md`

---

## ⚙️ Phase 0 — 환경 진단

Claude Code가 첫 질문 받으면 **즉시 bash/PowerShell로 아래 병렬 실행**하여 현재 기기 상태를 파악한다. (각 항목은 true/false만 내면 됨)

```bash
# 1) Claude Code 버전
claude --version 2>&1
# 2) Node / Git / gh
node --version && git --version && gh --version 2>&1
# 3) ~/.claude 상태 (git repo인지)
[ -d "$HOME/.claude/.git" ] && echo "claude-config: OK" || echo "claude-config: MISSING"
# 4) projects 동기화 상태
[ -d "$HOME/.claude/projects/.git" ] && echo "projects-sync: OK" || echo "projects-sync: MISSING"
# 5) GitHub 인증
gh auth status 2>&1 | head -3
# 6) 프로젝트 코드
[ -d "$HOME/Desktop/Claude/swresort/.git" ] && echo "swresort: OK" || echo "swresort: MISSING"
```

결과에 따라 Phase 1~3 중 필요한 단계만 실행.

---

## 🚀 Phase 1 — 기본 환경 복원 (bootstrap)

**공개 claude-config 레포의 bootstrap.ps1 실행** (Node·Git·gh·Claude Code·~/.claude 일괄 셋업)

```powershell
# PowerShell 관리자 권한
irm https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/bootstrap.ps1 | iex
```

이후 **사용자에게 요청**:
1. `claude` 실행 → Anthropic 계정 로그인
2. `gh auth login` → GitHub HTTPS 브라우저 인증

> **Claude Code 주의**: 이 두 단계는 사용자 대면 인증이라 Claude Code가 자동 대신할 수 없음. 상태만 체크.

---

## 🔐 Phase 2 — Private 레포 Clone (대화내역)

`~/.claude/projects/`에 `.git`이 없으면 (Phase 0 결과 `projects-sync: MISSING`) 다음 실행:

```powershell
git clone https://github.com/alfm1007-cloud/claude-projects-sync.git $HOME\.claude\projects
```

성공 시 이전 PC에서 있었던 모든 세션 jsonl이 복원된다 → `/resume`으로 대화 이어가기 가능.

**실패 시 트러블슈팅**:
- `Permission denied` → `gh auth login` 먼저 완료
- `Already exists and is not empty` → `Move-Item $HOME\.claude\projects $HOME\.claude\projects.old` 후 재시도

---

## 📁 Phase 3 — 프로젝트 레포 Clone

외근지에서 작업할 레포만 선택적으로:

```powershell
$base = "$HOME\Desktop\Claude"
New-Item -ItemType Directory -Path $base -Force | Out-Null
Set-Location $base

# 필수 (신원리조트)
git clone https://github.com/alfm1007-cloud/swresort.git

# 선택 (아고다 가격 수집 북마클릿)
git clone https://github.com/alfm1007-cloud/agoda-auto.git

# 성내동: private, 필요 시 gh auth 후
```

---

## 🗂️ 인프라 (이미 구축 완료된 자동화)

### 이중 레포 동기화 시스템

| 레포 | 공개성 | 내용 | 훅 동작 |
|------|--------|------|---------|
| `alfm1007-cloud/claude-config` | Public | `~/.claude/` (CLAUDE.md, memory/, ref/, hooks/, commands/, skills/) | Stop/SessionStart 자동 push/pull |
| `alfm1007-cloud/claude-projects-sync` | **Private** | `~/.claude/projects/` (대화내역 jsonl) | 동일 훅이 함께 sync |

> `.gitignore`: `projects/`는 claude-config에서 제외되어 있음. 두 레포 **무중복 완전 분리**.

훅 위치: `~/.claude/settings.json` → `hooks.SessionStart` / `hooks.Stop`
→ `for d in ~/.claude ~/.claude/projects; do ...; done` 루프로 두 레포 순차 처리.

### 파일 저장 경로 (바탕화면 루트 금지)

| 용도 | 경로 |
|------|------|
| 프로젝트 코드 | `~/Desktop/Claude/{프로젝트명}/` |
| HTML 미리보기 | `~/Desktop/Claude/미리보기/` |
| 보고서/문서 | `~/Desktop/Claude/문서/` |

---

## 📊 프로젝트 현황 (2026-04-21 기준)

### swresort (신원리조트 예약 관리) — 주력

- **URL**: https://swresort.onrender.com
- **GitHub**: alfm1007-cloud/swresort (Private)
- **로컬**: `~/Desktop/Claude/swresort`
- **스택**: Vanilla JS SPA + Express + Supabase + Claude Haiku + PWA
- **배포**: Render 통합 (자동) · Netlify 임시 잔존
- **최신 커밋**:
  - `ac32be2` feat(handover): 동시 편집 감지 Realtime 구독
  - `e24463c` refactor(js): split 2076-line app.js into 9 domain modules
  - `17a32a8` fix(mobile): topbar 글자 세로쓰기 현상 해결 (≤640px)

**프로젝트별 세부 규칙**: `swresort/CLAUDE.md` (자동 로드됨)

### agoda-auto (아고다 가격 수집)

- 북마클릿 기반. swresort와 Supabase 공유 (`agoda_queue` 테이블)
- `~/Desktop/Claude/agoda-auto`

### 성내동 (호텔 운영 · private)

- 라마다 태백 관련 문서/운영
- 필요 시 별도 안내

---

## 📝 최근 작업 컨텍스트 (외근 이어 작업 시 참고)

### 이번 주 완료 (2026-04-20~21)

1. **모바일 topbar UI 픽스** — `.nav-right` flex 요소들이 세로로 쪼개지던 현상. `@media(max-width:640px)` + `flex-shrink:0 + overflow-x:auto`로 해결
2. **js/app.js 2076줄 → 9개 도메인 모듈 분리**:
   - core / utils / auth / request / list / suggest / sms / notif / parking
   - sw.js v7→v8, ASSETS에 9개 모듈 precache
3. **handover 동시 편집 Realtime 구독** — `handover_docs` UPDATE 이벤트를 열린 문서 단위로 구독. 편집 중이면 경고 토스트, 뷰 모드면 자동 리로드. 자기 저장은 `updated_by===user.id`로 필터링

### 다음 작업 후보 (우선순위 순)

| # | 제목 | 규모 | 추천도 |
|---|------|------|--------|
| 1 | 예약 리스트 Realtime 편집 충돌 UX | 소 | ⭐⭐⭐ handover B와 패턴 동일, 저비용 |
| 2 | list.js 433줄 추가 분리 | 중 | ⭐⭐ |
| 3 | handover 낙관적 잠금 (`updated_at` 불일치 시 저장 거부) | 중 | ⭐⭐⭐ Realtime B 확장 |
| 4 | PWA SW 업데이트 UX (새 버전 배너) | 중 | ⭐⭐ |
| 5 | 브릿지엠 SMS 실연동 | 대 | 사용자 지시 필요 |
| 6 | 입금 자동 확인 Webhook | 대 | 사용자 지시 필요 |
| 7 | 아고다 AI 에이전트 | 대 | 사용자 지시 필요 |
| 8 | 즉시 예약 페이지 | 대 | 사용자 지시 필요 |

> **외근 중 진행 규칙**: 사용자 확인 없이 1~4 중 하나 "시작"해도 된다. 단 커밋/배포 전에 항상 확인받기. 5~8은 반드시 사용자 지시 필요.

---

## 🛠️ 인프라 & 환경변수 (참고)

### Render 대시보드 ENV (원본, 별도 백업 없음)

| 키 | 용도 |
|----|------|
| `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY` / `SUPABASE_SECRET_KEY` | DB/Auth |
| `ANTHROPIC_API_KEY` | Claude Haiku |
| `VAPID_PUBLIC_KEY` / `VAPID_PRIVATE_KEY` / `VAPID_EMAIL` | Web Push |
| `NICEPARK_ID` / `NICEPARK_PW` | 주차 API |

> 분실 시 재발급 경로: `swresort/CLAUDE.md §7` 참조.
> **외근지에서 `server.js`를 로컬 실행할 일이 있으면** Render 대시보드에서 위 값들 복사 필요. 배포만 할 거면 불필요.

### 공통 모니터링

- **UptimeRobot**: 10분 주기 keep-alive 핑 (Render 콜드스타트 방지)
- **Sentry**: 성내동만 연동. swresort 미연동.

상세: `~/.claude/memory/infrastructure.md`

---

## 🆘 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `bootstrap.ps1` 실행 거부 | PowerShell 정책 | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` → `Y` |
| `claude` 명령 못 찾음 | PATH 갱신 안 됨 | 새 PowerShell 열기 / 재부팅 |
| private 레포 clone 실패 | `gh auth login` 미완료 | 먼저 인증 후 재시도 |
| Stop hook 에러 로그 | git push 충돌 | `cd ~/.claude && git pull --rebase && git push` 수동 |
| `/resume`에 세션 없음 | projects-sync clone 안 됨 | Phase 2 재실행 |
| Realtime 미작동 (swresort) | Supabase publication 미등록 | Dashboard → Database → Replication → `supabase_realtime` → 테이블 ON |
| Web Push 403 | VAPID 키 불일치 | `push_subscriptions` 전체 삭제 → 전 기기 재구독 |

더 많은 오류 패턴: `~/.claude/ref/errors.md`

---

## 📦 참고 파일 (자동 로드됨)

- `~/.claude/CLAUDE.md` — 전역 규칙 요약
- `~/.claude/ref/rules.md` — 0원칙 전문
- `~/.claude/ref/errors.md` — 오류 체크리스트
- `~/.claude/ref/project_template.md` — 새 프로젝트 CLAUDE.md 뼈대
- `~/.claude/memory/MEMORY.md` — 프로젝트 메모리 인덱스
- `~/.claude/memory/infrastructure.md` — 인프라 전체 프로필
- `~/.claude/memory/user_identity.md` · `dev_context.md` · `planning_context.md` · `design_context.md`
- `swresort/CLAUDE.md` — swresort 고유 규칙 (작업 시 자동 로드)

---

## ✅ Claude Code 최종 체크 (셋업 후 사용자에게 보고)

```
📍 셋업 완료 상태
- [O/X] Node / Git / gh / Claude Code 설치
- [O/X] ~/.claude (claude-config) 동기화
- [O/X] ~/.claude/projects (claude-projects-sync) 동기화
- [O/X] Anthropic 로그인
- [O/X] GitHub 인증
- [O/X] swresort clone 완료

🎯 작업 재개 가능 여부: YES / NO
🎯 대기 중 작업: MANUAL §"다음 작업 후보" 참조
```

검증 질문: 사용자가 "내가 누구야?" 물으면 → "무르 · 기획부 대리 · alfm1007@gmail.com"

---

## 🎯 한 줄 요약

> **새 PC → `irm bootstrap.ps1 | iex` → `claude` 로그인 → `gh auth login` → `git clone claude-projects-sync` (자동 권장) → swresort clone → `/resume` → 이어서 작업**

끝.
