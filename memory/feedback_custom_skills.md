---
name: 커스텀 스킬 설정
description: auto-run/sonnet-run/haiku-run 스킬 설치 경로 및 다른 컴퓨터 설치 방법
type: feedback
---

설치 경로: `C:\Users\alfm1\.claude\skills\`
GitHub 백업: `swresort/skills/`

새 컴퓨터 설치 (swresort pull 후):
- Windows: `xcopy /E /I skills\auto-run %USERPROFILE%\.claude\skills\auto-run`
- Mac/Linux: `cp -r skills/auto-run ~/.claude/skills/`
(sonnet-run, haiku-run 동일)
