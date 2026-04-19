# 무르 인프라 프로필

> 모든 프로젝트에 공통으로 적용되는 **무르의 인프라 사용 현황**.
> 프로젝트 독립적 (swresort든 성내동이든 공통).
> 실제 키 값은 이 파일에 저장하지 않음 — **위치·이름만**.

---

## ⚠️ Claude 흔한 실수 (먼저 박제)

- ❌ **"Netlify에 배포"** / "Netlify Functions" 언급 → 2026-04부터 **Render로 통합**. Netlify는 임시 잔존, 별도 요청 없으면 건드리지 말 것.
- ❌ "UptimeRobot 붙이는 거 어때요?" 제안 → **이미 쓰고 있음**. 기존 설정 확인이 먼저.
- ❌ swresort와 성내동 **Supabase 혼동** → 별개 프로젝트 2개, URL 다름.
- ❌ Supabase `anon key` / `service_role key` 지칭 → 무르는 **신규 키 체계** (`sb_publishable_...` / `sb_secret_...`) 사용 중.
- ❌ **Sentry를 swresort에도 있다고 가정** → 현재 **성내동만** 연동됨.
- ❌ "Secret Key 좀 확인해볼게요" 하고 대화에 붙여넣기 요청 → **금지**. Render ENV 대시보드 직접 확인하도록 안내.

---

## 1. 배포 현황 (2026-04 기준)

| 프로젝트 | 서버/API | 정적/프론트 | URL |
|---------|---------|------------|-----|
| **swresort** | Render | Render (통합) | `swresort.onrender.com` *(Netlify 임시 잔존: automatereservationcharacters.netlify.app)* |
| **성내동** | Render | Render | https://store-management-system-1u64.onrender.com/ |
| **agoda-auto** | 로컬 Node만 | — | — |

## 2. 주 사용 서비스 + 키 종류

| 서비스 | 용도 | 키 종류 | 저장 위치 |
|--------|------|---------|----------|
| **Supabase** | DB + Auth | Publishable (`sb_publishable_...`) + Secret (`sb_secret_...`) | Render ENV / index.html은 Publishable만 |
| **Anthropic Claude** | AI 분석 (Haiku) | `ANTHROPIC_API_KEY` | Render ENV |
| **Web Push VAPID** | PWA 알림 | PUBLIC / PRIVATE | Render ENV, PUBLIC만 index.html 하드코딩 |
| **NicePark** | 주차 등록 API | `NICEPARK_ID` + `NICEPARK_PW` | Render ENV (swresort/server.js:299-301) |
| **UptimeRobot** | keep-alive ping | 계정 로그인만 필요 | — |
| **Sentry** | 에러 모니터링 | DSN | 성내동 프로젝트 코드 내 (DSN은 공개 OK) |

## 3. Supabase 프로젝트 목록

| 프로젝트 | URL | Publishable Key (공개 가능) |
|---------|-----|--------------------------|
| **swresort** | `https://bczrzavslgxythrcszwj.supabase.co` | `sb_publishable_4VOqv9mp3Ayplz04mPpKVw_kvInHcKu` |
| **성내동** | `https://etymlcxtwzzginltfgdh.supabase.co` | `sb_publishable_ZWyikAbijYM26QIBzLHyNQ_bTyCvJt-` |

> Secret Key는 Render ENV에만 저장. 이 파일에 절대 기록 금지.

### 신규 API 키 체계 주의
- Publishable = 구 `anon key` 대체. **브라우저 노출 OK** (RLS가 방어)
- Secret = 구 `service_role key` 대체. **서버 전용, 클라이언트 절대 금지**
- 환경변수 명명 관행: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
- 기존 `anon` / `service_role` 탭도 Supabase 대시보드에 Legacy로 남아있음

## 4. Render Keep-alive (15분 cold start 회피)

**2중 체계**:
1. **내부**: 각 프로젝트 `server.js` 안의 `node-cron`이 14분마다 `/keep-alive` 자기 핑
2. **외부**: **UptimeRobot** Free 플랜 (50 monitors 중 2개 사용)
   - **모니터 1**: `https://swresort.onrender.com/keep-alive` — 10분 주기 HTTP
   - **모니터 2**: `https://store-management-system-1u64.onrender.com/health` — 10분 주기 HTTP
   - 알림 채널: 기본값 (UptimeRobot 가입 이메일)

## 5. 에러 모니터링 (Sentry)

| 프로젝트 | Sentry 연동 | Sentry 프로젝트명 |
|---------|-------------|-------------------|
| swresort | ❌ 미연동 | — |
| 성내동 | ✅ 연동됨 | `JAVASCRIPT-1` (Browser JavaScript SDK) |

- 조직: `alfm1007-cloud's Org`
- **SDK 설치 방식**: CDN bundle (`browser.sentry-cdn.com/8.47.0/bundle.min.js`)
- **init 위치**: `성내동/public/index.html:10-38` (인라인 `<script>`)
- **DSN**: `public/index.html:16` 평문 하드코딩 (DSN은 public 성격이라 OK, 환경변수 아님)
- **무료 티어 보호 설정**: `tracesSampleRate: 0` / `replaysSessionSampleRate: 0` / `replaysOnErrorSampleRate: 0` → **에러 캡처만, Performance/Replay 비활성**
- **사용자 식별**: `app.js:205-208` 에서 `Sentry.setUser({id, username, email})` + `setTag('store_id', 'role')`
- **노이즈 필터**: ResizeObserver, NetworkError, 확장프로그램 URL 등 ignoreErrors/denyUrls 등록됨
- Seer Autofix는 아직 미설정 (활성화 권장)
- 오류 확인 경로: Sentry 대시보드 → Issues → 해당 프로젝트

## 6. 로그 확인 경로 (프로젝트 전반)

| 종류 | 위치 |
|------|------|
| 서버 에러/요청 로그 | Render 대시보드 → 프로젝트 → Logs |
| DB 쿼리/Auth/스토리지 | Supabase 대시보드 → Reports |
| 프론트 JS 에러 | 성내동: Sentry / swresort: 브라우저 콘솔 수동 |
| Keep-alive 상태 | UptimeRobot 대시보드 |

## 7. 비밀 키 저장 원칙 (현재 상태)

**현재**: Render 대시보드 ENV가 **유일한 원본, 별도 백업 없음**.

**분실/노출 시 복구 절차**:
- **Supabase Secret Key**: Supabase 대시보드 → Settings → API Keys → Rotate → 새 키를 Render ENV에 재등록 → Render 자동 재배포
- **ANTHROPIC_API_KEY**: https://console.anthropic.com → API Keys → Create new
- **VAPID Keys**: 한 번 바꾸면 **모든 기기 재구독 필요** (`push_subscriptions` 전체 삭제)
- **NicePark 키**: 업체에 문의

**앞으로 개선 방향 (선택)**:
- [ ] 1Password/Bitwarden에 프로젝트별 키 볼트 하나 만들기 → Render ENV는 "복사본"이 됨. 분실 위험 ↓
- [ ] 한 달에 한 번 Render ENV 목록을 마스터 문서에 스냅샷

## 8. 도메인 / DNS

**커스텀 도메인 없음.** 모두 Render 기본 서브도메인 사용.

| URL | 프로젝트 | 비고 |
|-----|---------|------|
| `swresort.onrender.com` | swresort | Render 기본 |
| `store-management-system-1u64.onrender.com` | 성내동 | Render 기본 |
| `automatereservationcharacters.netlify.app` | swresort (임시) | Netlify 잔존, 별도 요청 없으면 무시 |

> swresort.kr / 라마다호텔앤리조트.kr / ramada-taebaek.com 등은 **외부 마케팅용 사이트**로 이 인프라와 무관.
> 커스텀 도메인 붙이게 되면 그 때 등록기관/DNS 콘솔 추가 박제.

---

## 9. 업데이트 트리거 (언제 이 파일을 고치는가)

- 새 서비스 가입 → 섹션 2·3 갱신
- 키 재발급 → 섹션 7 "최근 Rotate 일자" 기록 (선택)
- 배포 인프라 변경 (Render↔Netlify↔Vercel 등) → 섹션 1 갱신
- Sentry/모니터링 연동 추가 → 섹션 5 갱신
- 도메인 추가/이전 → 섹션 8 갱신
