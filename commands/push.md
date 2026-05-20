---
description: 라운드 push 자동화 — sw.js 캐시 bump + commit 양식 + push (성내동/swresort 공통)
---

# 라운드 push — 반복 작업 1줄 단축

성내동/swresort 같은 PWA 프로젝트의 라운드 push 흐름을 한 번에 처리.

## 절차 (Claude가 자동 실행)

1. **현재 상태 확인**
   - `git status --short`
   - `git log -1 --pretty=format:"%h %s"`
   - 마지막 커밋의 `vNN` 추출

2. **sw.js CACHE_NAME 자동 증가**
   - `public/sw.js` 또는 `service-worker.js` 검색
   - `CACHE_NAME = 'snd-vNN'` → `'snd-v(NN+1)'`
   - swresort 도 동일 패턴 (`swr-vNN`)

3. **5단계 검증 강제 — 사용자가 변경 의도를 1줄로 입력하지 않았으면 중단**
   - "$ARGUMENTS" 인자로 받음. 비었으면 "변경 의도 한 줄을 적어주세요" 토스트 후 중단.

4. **commit 메시지 자동 생성**
```
fix(Phase G vNN+1): <ARGUMENTS>

5단계 검증:
1) 변경 지점: ...
2) 데이터 흐름: ...
3) 중복 호출: ...
4) edge: ...
5) 사용자 행동: ...

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

5. **git add 변경 파일만 + commit + push**
   - `git add` 는 변경된 파일을 명시적으로 (`-A` 금지)
   - push 실패하면 (origin이 앞서면) `git fetch && git log HEAD..origin/master` 보여주고 중단

6. **결과 보고** — 사용자에게 1줄 요약: `✅ vNN+1 push 완료 (커밋 hash)`

## 안전장치
- `--force` 절대 사용 금지
- pre-commit hook 우회 금지 (`--no-verify` 금지)
- `--amend` 금지 (새 commit)
- 사용자 명시 허락 없이 다른 브랜치 push 금지

## 사용 예
- `/push 외상 결제 시 sale 중복 적립 방지` → 자동 v62→v63 + 커밋 + push
- `/push 회원 강의 컬럼 제거` → sw.js bump + commit + push
