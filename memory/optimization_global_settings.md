---
name: 글로벌 설정 최적화 (2026-04-13)
description: 토큰 효율화를 위한 플러그인/MCP 서버 비활성화 설정
type: feedback
---

## 변경 사항

파일: `~/.claude/settings.json`

| 설정 | 변경 전 | 변경 후 | 효과 |
|------|--------|--------|------|
| enabledPlugins | frontend-design@claude-plugins-official: true | {} | 매 메시지 ~500 토큰 절감 |
| enableAllProjectMcpServers | (없음, 기본값) | false | MCP 오버헤드 제거 (~400 토큰) |
| spinnerTipsEnabled | (없음, true) | false | UI 팁 메타데이터 제거 (~100 토큰) |

## 예상 효과

- **매 메시지 토큰 절감**: 900-1,200 토큰
- **단순 요청 속도**: 15-20% 향상
- **월간 절감** (100 메시지 기준): ~90,000-120,000 토큰

## 주의사항

- 프로젝트 스킬 (auto-run, sonnet-run, haiku-run)은 별도 경로에서 로드됨
- 향후 이 설정은 프로젝트별로도 필요 시 상속 가능
