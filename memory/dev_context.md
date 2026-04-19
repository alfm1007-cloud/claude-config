---
name: 개발 컨텍스트
description: 아고다 자동화, 웹사이트 관리, 개발 제약사항
type: project
---

## 아고다 자동화 (agoda-auto)

→ 모든 정보는 `Desktop/Claude/agoda-auto/CLAUDE.md` 참조 (도시코드, 제약, 조회 규칙, 진행 현황 모두 거기서 관리).

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
