# 자산 보호 6규칙 (정본)

> 박제 사유: 메인이 사용자 명시 없이 광범위 `git checkout -- file` 실행 → designer 작업물 280줄 손실 → 사용자 시간 수 시간 낭비. 재발 방지.
>
> 본 문서는 `~/.claude/CLAUDE.md` 의 "자산 보호 6규칙 요약" 섹션의 풀 텍스트 정본이다. 미묘한 판단(approved tag 발동 조건·hunk 단위 롤백 등) 시 반드시 참조.

## 규칙 1 — 파괴적 명령 default 잠금

`git checkout -- <file>`, `git reset --hard`, `rm <user-file>` 등 워킹트리·사용자 자산을 무가역적으로 날리는 명령은 셋 모두 충족 시에만 실행:
- 사용자 명시 키워드 ("롤백" / "되돌려" / "삭제" / "rollback")
- 대상 명시 (어느 파일·어느 변경)
- 잃을 내용 사전 보고 + 사용자 OK

그 외엔 절대 실행 X. "git 위생" 같은 메인 판단 핑계 금지.

## 규칙 2 — `git stash` 격리 default

의도 외 워킹트리 변경 발견 시 `git checkout -- ` 대신 `git stash push -m "이유"` 격리. 영구 손실 0, `git stash pop` 으로 항상 복구.

## 규칙 3 — designer/agent 결과물 외과적 분리

위임 전 `git diff --stat` 스냅샷. 위임 후 — 위임 범위 밖 파일 변경은 메인이 자동 stash 격리 + 본 commit 제외 + 사용자에 보고. 통합은 사용자 OK 후만.

## 규칙 4 — `approved-*` git tag 로 자산 추적 (메모리 비용 0)

사용자 명확 자산 승인 신호 시에만 자동 tag:
- ✅ tag 발동: 직전에 메인이 보여준 결과물(파일·디자인·구조)에 대한 승인 → "마음에 든다" / "훌륭해요" / "이대로 가자" / "합격" / "굿잡 (자산 맥락)"
- ❌ tag 발동 X: 단순 호응의 "OK" / 다음 작업 진행의 "응" / 일반 동의의 "그래"
- 🤔 애매하면: tag 찍기 전 1줄 확인 — "이거 `approved-<domain>-v<N>` 로 박제할까요?"

```
git tag approved-<domain>-v<N> -m "1줄 요약"
```
도메인 라벨: sales / schedule / members / inventory / points / ui-token / icons 등.
라운드 시작 시 `git tag --list "approved-*" --sort=-creatordate | head -20` 으로 직전 승인 자산 인지.
복원 시 `git checkout <tag> -- <file>` (외과적·정확). git refs 만 사용 → 메인 컨텍스트 누적 0줄, 무제한 확장.

## 규칙 5 — Render push 명시 키워드 강제

`git push origin master/main` 은 사용자가 **"push" / "배포" / "올려" / "deploy"** 명시한 직후 1회만. "OK" / "마음에 든다" 만으로는 push X (commit 도 보류). 워킹트리 변경은 파일에만 반영 → 사용자 dev (localhost) 검증 → 명시 push 명령 → 그제서야 commit + push.

## 규칙 6 — 부분 롤백은 hunk 단위

"X 부분만 롤백" 요청 시 — `git checkout -- file` (전체) 가 아니라 `git checkout -p` / `git restore -p` (hunk 단위 selective). 원한 변경만 정확히 되돌리고 무관 변경 보존.
