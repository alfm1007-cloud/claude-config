---
name: 개발 컨텍스트
description: 아고다 자동화, 웹사이트 관리, 개발 제약사항
type: project
---

## 아고다 자동화 (agoda-auto)

**파일 위치:** `C:\Users\alfm1\Desktop\Claude\agoda-auto\`

**제약:** Headless Playwright는 봇 차단 → CDP 연결 방식만 유효

**도시 코드:**
- 여수 = 213193
- 부산 = 17172
- 해운대 = 31212

**현황:**
- 호텔 목록 수집 ✅
- 객실 파싱 ❌
- 결제창 금액 추출 ❌

**조회 규칙:**
1. 결제 금액 = 예약하기 클릭 → 결제창 총금액
2. 최종 결제가 -20,000원 (뒤 세 자리 반올림)
3. 랜덤/현장 임의배정 제외
4. 환불 불가 시 "환불불가" 표기
5. 룸 이름만 구별 기재
6. 판매완료 호텔 제외 후 다음 이동
7. 국내 한정

---

## 웹사이트 현황

**swresort.kr**
- SEO 색인 이전 필요
- 구 도메인: swwghotel.free4u.co.kr → 301 리다이렉트 + Naver Search Advisor 등록

**vipcard.kr**
- 쿠폰 등록 404 오류
- 원인: jejucou.php 미이전
- 해결: 재개발 필요

**법적 필수 표기 누락:**
- 대표자 성명
- 통신판매업 신고번호

---

## swresort 개발 (프로젝트 지침)

CLAUDE.md 파일에 모든 기술 스택, 파일 구조, 환경변수, 오류 대응이 정의되어 있습니다.

**GitHub:** alfm1007-cloud/swresort (Private)
**CLAUDE.md:** 프로젝트 루트에 위치 (자동 로드)
