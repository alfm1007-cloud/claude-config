# 📘 MANUAL.md — Claude Code 자가 실행 플레이북 (Bulletproof Edition)

> **🤖 이 문서는 Claude Code 본인이 읽고 자체 실행하는 지시서다.**
> 사용자는 이 문서를 읽지 않는다. Claude Code가 대신 읽고 Bash/WebFetch/Write 도구로 모든 것을 실행한다.
>
> **사용자 발동 문구** (이 중 하나):
> - "깃허브 매뉴얼 확인하고 셋업해"
> - "MANUAL 봐줘" / "새 PC 셋업" / "외근 노트북 준비"
> - "회사 PC에 0원칙 동기화"
>
> **🎯 설계 원칙 (회사 PC 제약까지 대응)**
> 1. 사용자 **타이핑 0회**. 브라우저 클릭 최대 2회(Anthropic·GitHub).
> 2. Claude Code가 모든 단계를 도구로 직접 실행.
> 3. **3단계 폴백**: Tier A(풀 부트스트랩) → B(Git만) → C(WebFetch만). 회사 PC 제약으로 A/B 실패해도 C는 반드시 성공.
> 4. 각 단계마다 **실패 감지 → 다음 Tier 자동 전환**. 절대 "막혀서 멈춤" 금지.
> 5. 0원칙·규칙·컨텍스트 파일은 **Tier C(WebFetch)만으로도 완전 복원** 가능.

공개 원본: https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/MANUAL.md

---

## 👤 사용자 정체성 (즉시 내재화)

- **이름**: 무르 (본명 금지)
- **이메일**: alfm1007@gmail.com
- **UID**: `7229bd82-dd39-43e4-9f25-90e9ebf60b1a`
- **역할**: 기획부 대리
- **언어**: 한국어
- **성향**: 실용적·직접적, 비효율·아부·감상 기피, 결과·근거·대안 선호

---

## 🔒 0원칙 (최우선)

**"현재 상황을 먼저 확인하고, 근거를 인용한 뒤, 근거 기반으로 제안한다."**

- 응답 템플릿: 📍 현재 상태 → 💡 제안 → 🎯 내 의견
- 모르면 "확인 안 됨" 라벨 + 질문. 감으로 약속 금지.
- 상세 전문은 `~/.claude/ref/rules.md` 복원 후 참조

---

## 🚦 Phase 0 — 환경 진단 & Tier 결정

**Claude Code가 자체 실행 (Bash 도구, 병렬)**:

```bash
# --- 1. 기본 환경 ---
echo "=== [OS] ===" && uname -a 2>&1 | head -1
echo "=== [HOME] ===" && echo "$HOME"
echo "=== [writable] ===" && touch "$HOME/.claude-test-write" 2>&1 && rm "$HOME/.claude-test-write" && echo "OK"

# --- 2. 커맨드 존재 ---
echo "=== [node] ===" && (command -v node && node --version) 2>&1
echo "=== [git] ===" && (command -v git && git --version) 2>&1
echo "=== [gh] ===" && (command -v gh && gh --version | head -1) 2>&1
echo "=== [claude] ===" && (command -v claude && claude --version) 2>&1
echo "=== [curl] ===" && (command -v curl && curl --version | head -1) 2>&1
echo "=== [winget] ===" && (command -v winget || echo "MISSING") 2>&1

# --- 3. 네트워크 (회사 방화벽 체크) ---
echo "=== [net:github-raw] ===" && curl -sSf -o /dev/null -w "%{http_code}\n" https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/MANUAL.md 2>&1
echo "=== [net:github-api] ===" && curl -sSf -o /dev/null -w "%{http_code}\n" https://api.github.com 2>&1
echo "=== [net:anthropic] ===" && curl -sSf -o /dev/null -w "%{http_code}\n" https://api.anthropic.com 2>&1

# --- 4. 현재 동기화 상태 ---
echo "=== [~/.claude/.git] ===" && [ -d "$HOME/.claude/.git" ] && echo OK || echo MISSING
echo "=== [~/.claude/CLAUDE.md] ===" && [ -f "$HOME/.claude/CLAUDE.md" ] && echo OK || echo MISSING
echo "=== [~/.claude/ref/rules.md] ===" && [ -f "$HOME/.claude/ref/rules.md" ] && echo OK || echo MISSING
echo "=== [~/.claude/projects/.git] ===" && [ -d "$HOME/.claude/projects/.git" ] && echo OK || echo MISSING
echo "=== [gh auth] ===" && gh auth status 2>&1 | head -3
echo "=== [swresort] ===" && [ -d "$HOME/Desktop/Claude/swresort/.git" ] && echo OK || echo MISSING

# --- 5. PowerShell 실행 정책 (Windows만) ---
echo "=== [psexec-policy] ===" && powershell -NoProfile -Command "Get-ExecutionPolicy -Scope CurrentUser" 2>&1
echo "=== [admin] ===" && powershell -NoProfile -Command "([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)" 2>&1
```

### Tier 자동 결정 로직

Claude Code는 Phase 0 결과를 보고 다음을 판단:

| 조건 | 선택 Tier |
|------|-----------|
| winget OK + 관리자 + git/node 없음 | **Tier A** (full bootstrap) |
| git 있음 + winget 없음/비관리자 | **Tier B** (git-only, skip winget install) |
| **git 막힘** 또는 npm 설치 실패 예상 | **Tier C** (WebFetch-only 폴백) |
| github-raw HTTP != 200 | 네트워크 문제 → 사용자 확인 요청 (회사 방화벽) |

> **Tier는 배타적이 아님**. A 시도 → 실패 시 B → 실패 시 C로 자동 하향.

---

## 🅰️ Tier A — 풀 부트스트랩 (이상적 환경)

**조건**: winget 있음, 관리자 권한, 인터넷 OK

**Claude Code 실행**:
```powershell
# 1. ExecutionPolicy 선제 허용
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force 2>$null

# 2. 부트스트랩
irm https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/bootstrap.ps1 | iex
```

bootstrap.ps1이 자동 수행:
- Node / Git / gh / Claude Code 설치 (winget + npm)
- `git clone claude-config` → `~/.claude/`
- settings.json 훅 배포
- `~/Desktop/Claude/` 디렉터리 준비

**실패 시** → Tier B 또는 C 자동 전환.

---

## 🅱️ Tier B — Git만으로 복원 (회사 PC 일반적 시나리오)

**조건**: git은 이미 있음. winget/npm 제약 있음.

**Claude Code 실행**:

```bash
# 1. claude-config clone (공개 레포, 인증 불필요)
if [ ! -d "$HOME/.claude/.git" ]; then
  if [ -d "$HOME/.claude" ]; then
    mv "$HOME/.claude" "$HOME/.claude.backup-$(date +%Y%m%d%H%M%S)"
  fi
  git clone https://github.com/alfm1007-cloud/claude-config.git "$HOME/.claude"
fi

# 2. 결과 확인
[ -f "$HOME/.claude/CLAUDE.md" ] && [ -f "$HOME/.claude/ref/rules.md" ] && echo "Tier B 성공"
```

**이것만 성공하면 0원칙·규칙·컨텍스트 전부 복원** (명령어 타이핑 없이 Claude Code가 직접 실행).

### Tier B — 선택 확장 (gh auth 있을 때)

private 대화내역 레포:
```bash
if gh auth status 2>&1 | grep -q "Logged in"; then
  if [ ! -d "$HOME/.claude/projects/.git" ]; then
    [ -d "$HOME/.claude/projects" ] && mv "$HOME/.claude/projects" "$HOME/.claude/projects.old.$(date +%s)"
    git clone https://github.com/alfm1007-cloud/claude-projects-sync.git "$HOME/.claude/projects"
  fi
fi
```

**실패 시** → Tier C 자동 전환.

---

## 🅲 Tier C — WebFetch 폴백 (git 막힌 회사 PC 최후 수단)

**조건**: git 자체가 차단/미설치. curl 또는 Claude Code WebFetch만 사용.

**Claude Code 실행**: 아래 **파일 매니페스트**의 모든 파일을 WebFetch/curl로 받아 로컬에 기록.

### 파일 매니페스트 (Tier C에서 사용)

Claude Code는 아래 목록을 순회하며 각 파일을 `https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/{path}`에서 받아 `$HOME/.claude/{path}`에 저장.

```
CLAUDE.md
README.md
MANUAL.md
SETUP.md
.gitignore
commands/sync.md
hooks/auto-pull.ps1
hooks/auto-push.ps1
memory/MEMORY.md
memory/design_context.md
memory/dev_context.md
memory/feedback_custom_skills.md
memory/feedback_token_efficiency.md
memory/infrastructure.md
memory/optimization_global_settings.md
memory/planning_context.md
memory/user_identity.md
ref/errors.md
ref/project_template.md
ref/rules.md
```

**자동화 스크립트** (Claude Code가 직접 실행):

```bash
BASE="https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master"
TARGET="$HOME/.claude"
mkdir -p "$TARGET/commands" "$TARGET/hooks" "$TARGET/memory" "$TARGET/ref"

files=(
  "CLAUDE.md" "README.md" "MANUAL.md" "SETUP.md" ".gitignore"
  "commands/sync.md"
  "hooks/auto-pull.ps1" "hooks/auto-push.ps1"
  "memory/MEMORY.md" "memory/design_context.md" "memory/dev_context.md"
  "memory/feedback_custom_skills.md" "memory/feedback_token_efficiency.md"
  "memory/infrastructure.md" "memory/optimization_global_settings.md"
  "memory/planning_context.md" "memory/user_identity.md"
  "ref/errors.md" "ref/project_template.md" "ref/rules.md"
)

for f in "${files[@]}"; do
  echo "fetching $f ..."
  curl -sSL "$BASE/$f" -o "$TARGET/$f" && echo "  OK" || echo "  FAIL"
done

# 검증
echo "=== 파일 검증 ==="
ls -la "$TARGET/CLAUDE.md" "$TARGET/ref/rules.md" "$TARGET/memory/MEMORY.md"
```

**대체 방법** (curl 도 막힌 극단 환경):
Claude Code는 **WebFetch 도구**로 각 raw URL을 직접 받아 **Write 도구**로 로컬 파일 작성. 이 경우 외부 명령이 전혀 필요 없음.

**Tier C 한계**:
- `~/.claude`가 git 저장소가 아니므로 **자동 push/pull 훅 작동 안 함**
- 세션 종료 후 변경사항은 다음 세션에서 **사용자가 명시적으로 동기화 요청**해야 함
- 그러나 **0원칙 및 모든 참고 파일은 완전 복원됨** → 즉시 정상 작업 가능

---

## 🔐 인증 (Phase 2)

### Anthropic 로그인
- Claude Code가 **이미 실행 중**이라면 이미 인증된 상태. 스킵.
- 신규 설치 직후라면 사용자가 `claude`를 최초 실행 시 브라우저 자동 열림 → 클릭 1회 → 완료.

### GitHub 인증 (Tier B private 레포 필요 시만)

**Claude Code 자동 실행**:
```powershell
gh auth login --hostname github.com --git-protocol https --web --scopes "repo,read:org"
```

사용자에게 안내:
> "브라우저가 열렸습니다. 표시된 8자리 코드를 입력한 뒤 Authorize 버튼을 눌러주세요."

완료 검증:
```bash
gh auth status 2>&1 | grep "Logged in to github.com"
```

**gh 자체가 설치 안 된 회사 PC**라면 Tier C로 진행하고 private 레포(대화내역)는 스킵 — 필수 아님.

---

## 📁 Phase 3 — 프로젝트 레포 Clone

**Claude Code 자동 실행** (Tier A/B에서만, C는 스킵 가능):

```bash
mkdir -p "$HOME/Desktop/Claude"
cd "$HOME/Desktop/Claude"

# 공개 레포 (인증 불필요)
[ ! -d "swresort/.git" ] && git clone https://github.com/alfm1007-cloud/swresort.git
[ ! -d "agoda-auto/.git" ] && git clone https://github.com/alfm1007-cloud/agoda-auto.git 2>/dev/null
```

---

## ✅ Phase 4 — 검증 & 최종 보고

**Claude Code 자체 실행 후 사용자에게 보고**:

```bash
echo "=== 최종 검증 ==="
echo "[Tier 선택]: A / B / C 중 어떤 경로로 복원되었는지 명시"
ls "$HOME/.claude/CLAUDE.md" "$HOME/.claude/ref/rules.md" "$HOME/.claude/memory/MEMORY.md" 2>&1
[ -d "$HOME/.claude/.git" ] && echo "git-synced: YES" || echo "git-synced: NO (WebFetch only)"
[ -d "$HOME/.claude/projects/.git" ] && echo "projects-sync: YES" || echo "projects-sync: NO"
[ -d "$HOME/Desktop/Claude/swresort/.git" ] && (cd "$HOME/Desktop/Claude/swresort" && git log --oneline -1)
```

### 보고 템플릿

```
📍 셋업 완료 보고 (Tier {A|B|C} 경로)

✅ 사용자 정체성 내재화: 무르 · 기획부 대리
✅ 0원칙 로드: ~/.claude/ref/rules.md
✅ 참고 파일 복원: CLAUDE.md / memory/*.md / ref/*.md
{git-synced ? "✅ git 동기화 활성 (Stop/SessionStart 훅)" : "⚠ WebFetch 복원 (git 미사용, 동기화 수동)"}
{projects-sync ? "✅ 대화내역 동기화" : "⚠ 대화내역 없음 (gh auth 또는 git 제약)"}
{swresort ? "✅ swresort 프로젝트: 최신 {SHA}" : "— swresort 미clone (요청 시 실행)"}

🎯 다음 행동:
  - 이전 대화 이어가기: /resume
  - 새 작업 지시 대기 중

⚠ 제약사항 (있으면):
  - 회사 PC 방화벽/권한 제약으로 {X} 단계 실패 → {Tier N}로 폴백했음
  - {git-synced 아닐 경우} 세션 변경 자동 동기화 없음 → 수동 /sync 필요
```

---

## 🏢 회사 PC 특화 이슈 & 자동 대응

| 증상 | 원인 | Claude Code 자동 대응 |
|------|------|---------------------|
| `irm` 실행 거부 | ExecutionPolicy Restricted | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force` 선제 실행 |
| winget 없음 | Windows Store 제한 | Tier B/C로 폴백 (winget 불필요) |
| npm 설치 권한 거부 | 비관리자 | Claude Code 기설치 가정하고 Tier B로 진행 |
| git clone 403/커넥션 끊김 | 회사 프록시/방화벽 | Tier C로 폴백 (curl/WebFetch만 사용) |
| curl도 차단 | 극단 환경 | Claude Code **WebFetch 도구** 직접 사용 (외부 바이너리 없음) |
| `~/.claude` 쓰기 금지 | OneDrive 동기화 폴더 제약 | `$env:CLAUDE_HOME`로 경로 변경 후 재시도 + 사용자 통지 |
| raw.githubusercontent.com 차단 | SSL MITM 프록시 | 사용자에게 회사 프록시 CA 인증서 신뢰 필요 통지 |
| settings.json 병합 충돌 | 기존 사용자 설정 존재 | 백업 후 새 설정 merge (jq 없으면 PowerShell로 JSON 파싱) |
| Anthropic API 차단 | 회사 네트워크 | Claude Code 사용 자체 불가 — 이는 사용자가 모바일 테더링 등으로 우회 |
| OneDrive가 `.claude` 동기화 | Windows 기본 | `.gitignore` 경로에 OneDrive 제외 안내 + `$HOME/.claude`가 OneDrive 외부인지 확인 |

---

## 🗂️ 기존 구축된 자동화 인프라

### 이중 레포 동기화

| 레포 | 공개성 | 내용 | 훅 |
|------|--------|------|------|
| `alfm1007-cloud/claude-config` | Public | `~/.claude/` 전역 설정 | Stop/SessionStart 자동 push/pull |
| `alfm1007-cloud/claude-projects-sync` | **Private** | `~/.claude/projects/` 대화내역 | 동일 훅이 두 레포 루프 처리 |

훅 위치: `~/.claude/settings.json` → hooks.SessionStart / hooks.Stop
루프: `for d in ~/.claude ~/.claude/projects; do ...; done`

### 파일 저장 경로 규칙

| 용도 | 경로 |
|------|------|
| 프로젝트 코드 | `~/Desktop/Claude/{프로젝트명}/` |
| HTML 미리보기 | `~/Desktop/Claude/미리보기/` |
| 보고서/문서 | `~/Desktop/Claude/문서/` |

---

## 📊 프로젝트 현황 (2026-04-21 기준)

### swresort (신원리조트 예약 관리) — 주력

- URL: https://swresort.onrender.com
- 스택: Vanilla JS SPA + Express + Supabase + Claude Haiku + PWA
- 배포: Render 통합
- 최신 커밋:
  - `ac32be2` feat(handover): 동시 편집 감지 Realtime 구독
  - `e24463c` refactor(js): split 2076-line app.js into 9 domain modules
  - `17a32a8` fix(mobile): topbar 글자 세로쓰기 현상 해결 (≤640px)
- 세부 규칙: `swresort/CLAUDE.md` (작업 시 자동 로드)

### agoda-auto — 아고다 가격 수집 북마클릿
### 성내동 — 호텔 운영 (private, 요청 시)

---

## 📝 최근 작업 컨텍스트 (외근 이어 작업)

### 완료 (2026-04-20~21)
1. 모바일 topbar UI 픽스 (`@media(max-width:640px)` + flex 재정비)
2. js/app.js 2076줄 → 9개 도메인 모듈 분리 + sw.js v7→v8
3. handover 동시 편집 Realtime 구독

### 다음 작업 후보
| # | 제목 | 규모 | 추천 |
|---|------|------|------|
| 1 | 예약 리스트 Realtime 편집 충돌 UX | 소 | ⭐⭐⭐ |
| 2 | list.js 433줄 추가 분리 | 중 | ⭐⭐ |
| 3 | handover 낙관적 잠금 (updated_at 비교) | 중 | ⭐⭐⭐ |
| 4 | PWA SW 업데이트 UX (새 버전 배너) | 중 | ⭐⭐ |
| 5~8 | 브릿지엠 SMS / 입금 Webhook / 아고다 AI / 즉시 예약 | 대 | 지시 필요 |

외근 중 규칙: 1~4 중 시작 가능. 커밋/배포 전 확인. 5~8 사용자 지시 필수.

---

## 🛠️ Render ENV (참고)

| 키 | 용도 | 조달 |
|----|------|------|
| `SUPABASE_*` | DB/Auth | Supabase Dashboard → API |
| `ANTHROPIC_API_KEY` | Claude Haiku | console.anthropic.com |
| `VAPID_*` | Web Push | `npx web-push generate-vapid-keys` |
| `NICEPARK_ID/PW` | 주차 API | NicePark 업체 발급 |

로컬 `server.js` 실행 시만 복사. 상세: `swresort/CLAUDE.md §7`

---

## 🆘 일반 트러블슈팅

| 증상 | Claude Code 자동 대응 |
|------|---------------------|
| bootstrap 스크립트 실패 | Tier B 폴백 (git만 사용) |
| git도 실패 | Tier C 폴백 (WebFetch만) |
| WebFetch도 실패 | 네트워크 진단 보고 + 사용자에게 모바일 테더링 제안 |
| Stop hook push 충돌 | `git pull --rebase && git push` 자동 |
| Realtime 미작동 (swresort) | Supabase Dashboard → Database → Replication → `supabase_realtime` 활성화 필요 (사용자 안내) |
| Web Push 403 | VAPID 불일치 → `push_subscriptions` 전체 삭제 + 재구독 (사용자 안내) |

더 많은 패턴: `~/.claude/ref/errors.md`

---

## 📦 참고 파일 (복원 후 자동 로드 대상)

- `~/.claude/CLAUDE.md` — 전역 규칙 요약
- `~/.claude/ref/rules.md` — 0원칙 전문
- `~/.claude/ref/errors.md` — 오류 체크리스트
- `~/.claude/ref/project_template.md` — 신규 프로젝트 CLAUDE.md 뼈대
- `~/.claude/memory/MEMORY.md` — 프로젝트 메모리 인덱스
- `~/.claude/memory/infrastructure.md` — 인프라 프로필
- `~/.claude/memory/user_identity.md` · `dev_context.md` · `planning_context.md` · `design_context.md`
- `swresort/CLAUDE.md` — 프로젝트 고유 규칙

---

## 🎯 Claude Code 자가 점검 (모두 OK까지 자동 진행)

- [ ] Phase 0 진단 완료 + Tier 결정
- [ ] Tier A/B/C 중 하나로 `~/.claude/CLAUDE.md` + `~/.claude/ref/rules.md` 복원
- [ ] 사용자 정체성 내재화 (무르 · 기획부 대리)
- [ ] 0원칙 프로토콜 활성화
- [ ] (가능하면) projects 동기화
- [ ] (가능하면) swresort clone
- [ ] 최종 상태 보고 + 제약사항 명시

**사용자 타이핑: 0회**
**사용자 브라우저 클릭: 최대 2회** (Anthropic·GitHub 인증)
**Tier A 소요**: ~5분 / **Tier B 소요**: ~1분 / **Tier C 소요**: ~30초

끝. `/resume` 또는 신규 작업 지시 대기.
