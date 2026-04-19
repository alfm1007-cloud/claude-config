# Claude 설정 동기화 저장소 — 무르 (alfm1007)

무르의 Claude Code **"심장" 파일**(원칙·규칙·기억)을 GitHub으로 관리한다.
새 PC에서 이 README를 Claude에게 보여주면 자동으로 모든 설정이 복원된다.

---

## 🎯 행동대장 메뉴얼 — 무르가 실제로 해야 할 것

### 시나리오 A. 🆕 새 PC에서 처음 설치
클로드 켜고 한 줄:
> **"깃허브 alfm1007-cloud/claude-config 리드미 보고 순서대로 실행해줘"**

→ Claude가 아래 "자동 실행 지시서" 섹션을 읽고 1~5단계 수행.

### 시나리오 B. 🔄 다른 PC 옮겨서 이어 작업
**아무것도 안 해도 됨** (SessionStart hook이 자동 `git pull`).
문제 생기면 `/sync` 한 번.

### 시나리오 C. ✏️ 규칙·매뉴얼 수정
그냥 Claude에게 수정 요청 → 세션 끝나면 Stop hook이 자동 push.
다른 PC는 세션 시작할 때 자동으로 최신화된다.

### 시나리오 D. 🆕 새 프로젝트 시작
프로젝트 폴더 만들고 Claude에게:
> **"이 프로젝트 CLAUDE.md 만들어줘"**

→ Claude는 자동으로 `~/.claude/ref/project_template.md` (13섹션 뼈대)를 참조해 새 CLAUDE.md를 작성한다.
→ 프로젝트 고유 내용만 그 폴더 CLAUDE.md에, 전역 규칙은 `~/.claude/ref/rules.md` 참조.

### 시나리오 E. 🧠 원칙 확인
> **"rules.md 읽고 요약해줘"**

---

## 📂 파일 분리 철학

| 종류 | 위치 | 로드 시점 |
|------|------|-----------|
| **심장 (전역)** | `~/.claude/CLAUDE.md` + `ref/rules.md` | 모든 세션 자동 |
| **범용 참조** | `~/.claude/ref/errors.md`, `memory/*.md` | 필요 시 |
| **프로젝트 고유** | `프로젝트폴더/CLAUDE.md` | 그 폴더에서 작업할 때만 자동 |

전역에는 **프로젝트 독립적인 내용만** 둔다 (무르 신원, 0원칙, 저장경로, 범용 오류 패턴).
프로젝트 고유 내용(URL, 스택, DB 스키마 등)은 **프로젝트 CLAUDE.md로**.

---

## Claude에게: 자동 실행 지시서 (새 PC 설치)

### 1단계 — 현재 상태 확인
```bash
ls ~/.claude/
```
- `memory/`, `ref/`, `commands/`, `CLAUDE.md` 있음 → 4단계로
- 없음 → 2단계 진행

### 2단계 — 저장소 클론
```bash
git clone https://github.com/alfm1007-cloud/claude-config.git ~/claude-config-temp
cp -r ~/claude-config-temp/. ~/.claude/
rm -rf ~/claude-config-temp
```

### 3단계 — `~/.claude/settings.json` 에 hook 2개 추가
기존 파일이 있으면 `"autoUpdatesChannel"` 다음에 `"hooks"` 블록 병합.

```json
"hooks": {
  "SessionStart": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "cd ~/.claude && git pull --ff-only 2>/dev/null || true"
        }
      ]
    }
  ],
  "Stop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "cd ~/.claude && git diff --quiet && git diff --cached --quiet || (git add -A && git commit -m 'auto-sync: $(date +%Y-%m-%d)' && git push)"
        }
      ]
    }
  ]
}
```

- **SessionStart**: 세션 열 때 자동 `git pull --ff-only` (네트워크 없으면 조용히 스킵)
- **Stop**: 세션 끝날 때 변경 있으면 자동 `git add/commit/push`

### 4단계 — 동기화 확인
Claude Code 재시작 후:
```
/sync
```
"모두 최신 상태" 나오면 완료.

### 5단계 — 최종 보고
무르에게 다음을 체크리스트로 알려준다:
```
✅/❌ ~/.claude/ 파일 복원
✅/❌ settings.json 두 hook 설정
✅/❌ /sync 동작 확인
```

---

## 파일 구조

```
~/.claude/
├── CLAUDE.md              ← 전역 (모든 세션 자동 로드) — 무르 신원 + 포인터만
├── README.md              ← 이 파일 (행동대장 메뉴얼)
├── memory/
│   ├── MEMORY.md          ← 인덱스
│   ├── user_identity.md   ← 무르 기본 정보
│   ├── dev_context.md     ← 아고다/웹사이트
│   ├── planning_context.md← 라마다 운영·파트너십
│   ├── design_context.md  ← 3D 도면·인쇄물
│   ├── feedback_*.md, optimization_*.md ← 효율화 규칙
├── ref/
│   ├── rules.md           ← ⭐ 세션마다 반드시 읽기 (0원칙)
│   └── errors.md          ← 범용 오류·배포 체크리스트
└── commands/
    └── sync.md            ← /sync 커맨드 정의
```

**프로젝트별 CLAUDE.md는 각 프로젝트 폴더 안에 둔다:**
- `Desktop/Claude/swresort/CLAUDE.md` — 예약 관리
- `Desktop/Claude/agoda-auto/CLAUDE.md` — 아고다 자동화
- `Desktop/Claude/성내동/CLAUDE.md` — 매장 관리 PWA

---

## 운영 요약

| 상황 | 무르 행동 | 자동 처리 |
|------|-----------|-----------|
| 매뉴얼 수정 후 | 없음 | Stop hook → 자동 push |
| 다른 PC 이어 작업 | 없음 | SessionStart hook → 자동 pull |
| hook 실패/충돌 | `/sync` | 수동 동기화 |
| 새 PC | "리드미 보고 실행해줘" | Claude가 이 파일대로 실행 |
| 새 프로젝트 | "이 프로젝트 CLAUDE.md 만들어줘" | Claude가 `project_template.md` 참조해 생성 |

---

## 주요 프로젝트

| 프로젝트 | GitHub | 설명 |
|---------|--------|------|
| swresort | [alfm1007-cloud/swresort](https://github.com/alfm1007-cloud/swresort) | 신원리조트 예약 관리 |
| claude-config | [alfm1007-cloud/claude-config](https://github.com/alfm1007-cloud/claude-config) | 이 저장소 (심장) |
