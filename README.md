# Claude 설정 동기화 저장소 — 무르 (alfm1007)

이 레포는 무르의 Claude Code 설정, 원칙, 기억 파일을 관리합니다.
새 PC에서 이 README를 Claude에게 보여주면 Claude가 모든 설정을 자동으로 복원합니다.

---

## Claude에게: 새 PC 설치 지시서

아래 순서대로 자동 실행하세요.

### 1단계 — 현재 상태 확인

```bash
ls ~/.claude/
```

- `memory/`, `ref/`, `commands/`, `CLAUDE.md` 가 있으면 → 이미 설치됨, 4단계로 이동
- 없으면 → 2단계 진행

### 2단계 — 설정 파일 복원

```bash
git clone https://github.com/alfm1007-cloud/claude-config.git ~/claude-config-temp
cp -r ~/claude-config-temp/. ~/.claude/
rm -rf ~/claude-config-temp
```

### 3단계 — Stop hook 설정 (세션 종료 시 자동 push)

`~/.claude/settings.json` 에 아래 내용을 추가합니다.
기존 파일이 있으면 `"autoUpdatesChannel"` 항목 뒤에 추가하세요.

```json
"hooks": {
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

### 4단계 — 심볼릭 링크 연결 (Claude Code 실제 경로와 git 경로 통합)

```bash
# 현재 PC의 프로젝트 경로 확인 (alfm1 부분이 다를 수 있음)
ls ~/.claude/projects/

# 확인된 경로로 심볼릭 링크 연결 (경로 맞게 수정 후 실행)
rm -rf ~/.claude/ref
rm -rf ~/.claude/memory
ln -s ~/.claude/projects/[확인된경로]/ref ~/.claude/ref
ln -s ~/.claude/projects/[확인된경로]/memory ~/.claude/memory
```

> 예시: 경로가 `C--Users-alfm1-Desktop` 이면
> `ln -s ~/.claude/projects/C--Users-alfm1-Desktop/ref ~/.claude/ref`

### 5단계 — 동기화 확인

Claude Code에서 실행:
```
/sync
```

"모두 최신 상태" 가 나오면 완료입니다.

---

## 파일 구조

```
~/.claude/
├── CLAUDE.md              ← 세션마다 자동 로드 (프로젝트 지침)
├── memory/
│   ├── user_identity.md   ← 무르 기본 정보 (신원리조트 기획부 대리)
│   ├── dev_context.md     ← 개발 프로젝트 현황
│   ├── planning_context.md← 업무 스타일·파트너십
│   └── design_context.md  ← 디자인 작업 규칙
├── ref/
│   ├── rules.md           ← 작업 원칙 (매 세션 반드시 읽기)
│   ├── stack.md           ← 기술스택·파일구조·환경변수
│   ├── db.md              ← DB 테이블·RLS 정책
│   ├── features.md        ← 주요기능·관련사이트·개발예정
│   └── errors.md          ← 오류해결·배포 체크리스트
└── commands/
    └── sync.md            ← /sync 커맨드 정의
```

---

## 운영 방법

| 상황 | 할 일 |
|------|-------|
| 매뉴얼 수정 후 | 아무것도 안 해도 됨 (세션 종료 시 자동 push) |
| 다른 PC에서 최신화 | `/sync` 입력 |
| 새 PC 설치 | 이 README 순서대로 실행 |

---

## 주요 프로젝트

| 프로젝트 | GitHub | 설명 |
|---------|--------|------|
| swresort | [alfm1007-cloud/swresort](https://github.com/alfm1007-cloud/swresort) | 신원리조트 예약 관리 시스템 |
| claude-config | [alfm1007-cloud/claude-config](https://github.com/alfm1007-cloud/claude-config) | 이 저장소 |
