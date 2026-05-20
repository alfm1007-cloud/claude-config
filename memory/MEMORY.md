# Memory Index (정본)

> 모든 메모리는 이 폴더(`~/.claude/memory/`)에서만 관리한다.
> 작업 폴더별 자동로드 위치는 이 폴더로 포인터만 둔다.
> 자동로드 포인터: `~/.claude/projects/C--Users-alfm1-Desktop-Claude/memory/MEMORY.md`

## 📂 작업 효율화·구조 규칙
- [메인-서브 오케스트레이션](feedback_main_sub_structure.md) — 메인=오더 매니저, 위임 5요소, 0원칙 메타원칙, 박제 자제
- [토큰/비용 효율화](feedback_token_efficiency.md) — 파일 범위 확정, /compact 활용, 작업 단위 분리
- [커스텀 스킬](feedback_custom_skills.md) — auto-run·sonnet-run·haiku-run 위치
- [글로벌 설정 최적화](optimization_global_settings.md) — 플러그인·MCP 비활성화로 토큰 절감

## 📂 프로젝트 컨텍스트
- [무르 기본 정보](user_identity.md) — 신원리조트 기획부 대리, 라마다 태백 운영
- [개발 컨텍스트](dev_context.md) — agoda-auto, 웹사이트 관리
- [호텔 운영·파트너십](planning_context.md) — 라마다 태백, 협업사
- [디자인 작업](design_context.md) — 3D 도면, 인쇄물 카드
- [인프라 프로필](infrastructure.md) — 배포·키·모니터링·Sentry·UptimeRobot

## 📂 도메인별 피드백 (실패 사례 학습)
- [Palworld Modding 규칙](feedback_palworld_modding.md) — 실패 시 원상복귀, BP 이름 확인 필수

---

## 🗺 폴더 구조 (2026-04-30 통합 후)

```
~/.claude/memory/                          ← 정본 (모든 메모리)
~/.claude/projects/.../C-...-Claude/memory/MEMORY.md  ← 자동로드 포인터
~/.claude/projects/.../C-...-Desktop/_deprecated_memory_2026-04-30/  ← 구 B 폴더 (방치)
```
