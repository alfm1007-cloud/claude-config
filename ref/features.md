# 주요 기능 · 관련 사이트 · 개발 예정

## 역할 구분
- **처리자 (admin):** 전체 조회/수정/삭제, 문자 발송, 호텔 제안, 회원 관리, 아고다 기능
- **신청자 (sales):** 본인 신청 등록/조회, 호텔 선택/반려

## 로그인 방식
- 아이디 입력 → @swresort.internal 자동 추가 → Supabase Auth
- 이미 @ 포함된 경우 그대로 사용 (기존 이메일 계정 호환)

## 호텔 제안 흐름
```
신청자: 미신청 클릭 → status='requested' + 처리자 알림
처리자: 제안 클릭 → 최대 4개 호텔 입력 → 발송 → status='suggesting' + 신청자 알림
신청자: 카드 클릭 → 확인 팝업 → 선택 → hotel_name/amount 자동 반영 + 처리자 알림
       또는 반려(사유 필수) → status='processing' + 처리자 알림
```

## 아고다 가격 수집 (북마클릿)
- 처리자(admin) 전용 기능
- bookmarklet.html?uid=사용자ID&name=이름 → 개인 북마클릿 발행
- 아고다 결제 페이지에서 실행 → 호텔명/객실명/금액 자동 추출 → agoda_queue 테이블 저장
- 호텔 제안 모달 → "아고다 가격 불러오기" → 개인 큐에서 최대 4개 로드
- 금액 뒤 3자리 자동 000 처리

## 인수인계서 시스템 (/handover.html)
- 별도 페이지 (예약 시스템과 독립)
- 카테고리(무한 중첩) + 문서 구조
- 리치 텍스트 에디터 (editor.js)
- Ctrl+K 전체 검색 (제목·태그·본문)
- 편집 권한: profiles.can_edit_handover = true 인 계정만 가능
- Supabase 테이블: handover_categories, handover_docs (+ pg_trgm 확장)
- profiles 테이블에 can_edit_handover 컬럼 추가 필요 (sql/handover_schema.sql 실행)

## 주차관리 (NicePark 연동)
- 고객에게 주차 등록 링크 발송 → 고객이 직접 차량 선택 후 무료주차 등록
- parking_tokens 테이블: 예약 세션 관리 (체크인/체크아웃/차량번호/등록여부)
- NicePark API (npdc-i.nicepark.co.kr) 연동
- 체크인일~퇴실일 16:00까지 등록 가능
- 이미 등록된 차량 번호 뒤 4자리로 중복 체크
- 주차 취소 기능 포함

## 알림 시스템
- 인앱: Supabase Realtime WebSocket (폴링 없음)
- 백그라운드: Web Push (server.js /api/send-push)
- 편집 중 갱신 차단: isEditing 플래그 true 상태에서 loadList() 스킵

## SMS 발송
- 입금문자: 금액 입력 후 발송
- 예약문자: 필수값 9개 검증 (고객명/연락처/호텔명/투숙일/인원/박수/객실수/객실타입/예약번호)
- 예약문자 발송 성공 시 → 처리현황 자동 확정 + 신청자에게 알림

## PWA
- Android: Chrome → 설치
- iOS: Safari → 홈화면 추가 (iOS 16.4+ 필수)
- Web Push: PWA 설치 상태에서만 백그라운드 알림 작동

## 관련 사이트
| 항목 | URL |
|------|-----|
| 신원리조트 | https://www.swresort.kr |
| 라마다호텔앤리조트 | http://라마다호텔앤리조트.kr |
| 라마다태백 예약 | http://www.ramada-taebaek.com |
| Supabase | https://supabase.com/dashboard/project/bczrzavslgxythrcszwj |
| Netlify | https://app.netlify.com/sites/automatereservationcharacters |
| Render | https://dashboard.render.com |
| GitHub | https://github.com/alfm1007-cloud/swresort |

## 향후 개발 예정
- [ ] 브릿지엠 SMS API 실제 연동 (현재 시뮬레이션)
- [ ] 입금 자동 확인 (브릿지엠 수신 문자 Webhook → 파싱)
- [ ] 아고다 예약 자동 조회 (AI 에이전트 방식)
- [ ] 즉시 예약 가능 별도 페이지 구축
