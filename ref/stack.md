# 기술스택 · 파일구조 · 환경변수 · 배포설정

## 기술 스택
| 레이어 | 기술 |
|--------|------|
| 프론트엔드 | Vanilla JS — index.html 단일 파일 (SPA) |
| 백엔드 | Express (Node.js) — server.js → Render 배포 |
| DB / Auth | Supabase (bczrzavslgxythrcszwj, Seoul) |
| AI | Anthropic Claude Haiku (claude-haiku-4-5-20251001) |
| 주차 연동 | NicePark API (npdc-i.nicepark.co.kr) |
| 배포 | GitHub → Render (서버) + Netlify (정적 호스팅) |
| PWA | manifest.json + sw.js (Web Push 포함) |
| Keep-Alive | node-cron — Render 14분마다, Supabase 매주 월요일 |

## 파일 구조
```
swresort/
├── index.html              ← 메인 앱 전체 (프론트+로직 통합)
├── server.js               ← Express 백엔드 (API 전체 + keep-alive cron)
├── package.json            ← 의존성 (express, web-push, @supabase/supabase-js, node-cron)
├── sw.js                   ← Service Worker (PWA + Web Push 수신)
├── manifest.json           ← PWA 메타 정보
├── netlify.toml            ← Netlify 정적 호스팅 설정
├── bookmarklet.html        ← 아고다 가격 수집 북마클릿 설치 페이지
├── handover.html           ← 인수인계서 시스템 (별도 페이지)
├── handover/
│   ├── app.js              ← 인수인계서 앱 로직
│   ├── editor.js           ← 인수인계서 에디터
│   └── style.css           ← 인수인계서 스타일
├── sql/
│   └── handover_schema.sql ← 인수인계서 DB 스키마 (Supabase)
├── icon-192.png / icon-512.png
└── netlify/functions/      ← (구) Netlify Functions (현재 server.js로 통합)
```

## server.js API 엔드포인트
| 엔드포인트 | 기능 |
|-----------|------|
| POST /api/analyze | Claude Haiku AI 분석 |
| POST /api/send-push | Web Push 발송 |
| POST /api/create-user | Supabase Admin 계정 생성 |
| POST /api/delete-user | Supabase Admin 계정 삭제 |
| ALL /api/receive-hotel | 아고다 가격 큐 (GET/POST/DELETE) |
| ALL /api/nicepark-parking | NicePark 주차 등록/조회/삭제 |
| GET /keep-alive | Render 콜드스타트 방지용 |

## 환경변수 (Render 대시보드)
| 키 | 용도 |
|----|------|
| ANTHROPIC_API_KEY | Claude Haiku API |
| SUPABASE_URL | https://bczrzavslgxythrcszwj.supabase.co |
| SUPABASE_SERVICE_ROLE_KEY | Supabase Admin 작업 |
| VAPID_PUBLIC_KEY | Web Push 공개키 (BKM0OG...로 시작) |
| VAPID_PRIVATE_KEY | Web Push 비공개키 (Qd22XY...로 시작) |
| VAPID_EMAIL | mailto:alfm1007@gmail.com |

**index.html 내 하드코딩:**
- SUPABASE_URL, SUPABASE_KEY (anon)
- VAPID_PUBLIC: BKM0OG-hbooCYwuiP3n0BacSEsEK16dYCD479_vJGjLAQd22XYtec74yv7zMtQQ87SmHbjlqytS2I65DtcH8JnA
- Render API URL (index.html 내 API 호출 시 Render 주소 사용)
