# /sync — Claude 설정 동기화

~/.claude/ 의 현재 상태를 GitHub와 동기화합니다.

## 실행 순서

1. `git -C ~/.claude status` 로 변경 파일 확인
2. `git -C ~/.claude fetch` 로 원격 상태 비교
3. 상황에 따라:
   - 로컬에 변경 있음 → `git add -A` + `git commit` + `git push`
   - 원격이 앞서 있음 → `git pull`
   - 둘 다 변경 있음 → 충돌 파일 보고 후 사용자 판단
   - 변경 없음 → "모두 최신 상태" 보고
4. 결과 요약 보고

## 새 PC 최초 설치 시

```bash
git clone https://github.com/alfm1007-cloud/claude-config.git ~/claude-config-temp
cp -r ~/claude-config-temp/. ~/.claude/
rm -rf ~/claude-config-temp
```

그 다음 /sync 실행
