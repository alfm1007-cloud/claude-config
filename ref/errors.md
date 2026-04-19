# 오류 해결법 · 배포 체크리스트

## 자주 발생하는 오류
| 오류 | 원인 | 해결 |
|------|------|------|
| RLS로 특정 작업 막힘 | 정책 누락 | Supabase → Policies에서 테이블 정책 추가 |
| Web Push 403 BadJwtToken | VAPID 키 불일치 | push_subscriptions 전체 삭제 → 모든 기기 재구독 |
| Realtime 미작동 | Publications 미등록 | Supabase → Database → Publications → supabase_realtime → 테이블 ON |
| Functions 빌드 오류 | esbuild + web-push 충돌 | netlify.toml → node_bundler = "nft" 로 변경 |
| web-push require 실패 | package.json 위치 오류 | 루트 + netlify/functions/ 양쪽에 package.json 필요 |
| 인라인 편집 자동 닫힘 | Realtime 재렌더 | isEditing 플래그 true 상태에서 loadList() 스킵 확인 |
| 로그인 무반응 | JS 문법 오류 | F12 Console에서 오류 확인 |
| **"배포했다는데 반영 안됨"** | **commit만 하고 push 안 됨** | **항상 `git push origin master`까지 확인** |
| **upsert(onConflict) 중복 INSERT** | **DB에 UNIQUE 제약 없음 → onConflict silent 무력화** | **`create unique index ux_xxx on tbl(col1,col2,...)` 먼저** |
| **버튼 클릭 무반응(인쇄/저장 등)** | **체인 함수 중간에 사라진 DOM 참조 → TypeError → window.print/후속동작 안 됨** | **F12 Console 확인. HTML 정리 시 JS의 `getElementById` 모두 grep으로 동기 점검** |
| **흰 배경 위 흰 글씨 버튼** | **`btn-outline` 기본 배경(흰색)과 흰색 글자 인라인 스타일 충돌** | **다크 영역(카메라/모달 등)에선 `btn-outline` 쓰지 말고 인라인 `background:#fff;color:#XXX` 명시** |
| **toast/메시지가 안 사라짐** | **setTimeout 누락** | **메시지 표시 함수에 항상 자동 dismiss 타이머(보통 3~5초)** |

## 🛡️ 중복 데이터 방지 — 3중 방어 패턴 (출석/예약/주문 등)
같은 키 조합이 절대 두 번 들어가면 안 되는 데이터는 **반드시** 다음 3층 모두 적용:
```
1) 세션 캐시: const _doneSet = new Set();  // "key1|key2|key3"
   → 같은 브라우저 탭에서 즉시 차단 (네트워크 호출 X)
2) 클라이언트 사전 조회:
   const { data: existing } = await sb.from('tbl').select('id')
     .eq('key1',v1).eq('key2',v2).eq('key3',v3).maybeSingle();
   if (existing) { 사용자에게 안내 후 return; }
3) DB UNIQUE INDEX (최종 방어):
   create unique index if not exists ux_tbl_xxx on tbl(key1,key2,key3);
   → INSERT 시 duplicate 에러를 catch하여 중복 안내
```
**`upsert({ onConflict })`만 쓰는 것은 위험** — DB에 UNIQUE 없으면 그냥 INSERT가 됨.

## 🚨 silent error 금지
`try/catch`에서 토스트 한 번 띄우고 끝내면 함수 흐름이 죽어 **후속 동작(인쇄/리다이렉트/리로드 등) 누락**.
- 비치명 오류는 `console.error` 만 남기고 흐름 유지
- 치명 오류는 throw해서 호출자가 알게 함
- 중간 단계 실패가 다음 단계를 막아도 되는지 매번 판단

## 🚨 작업 완료 전 필수 체크
```
□ git status → "nothing to commit, working tree clean"
□ git log origin/master..HEAD → (비어있어야 함, 비어있지 않으면 push 필요)
□ git push origin master → 실제 원격 반영
□ 원격 배포(Render/Netlify) 트리거 확인
```
**"배포됐어요" 발언 전 반드시 push 확인. commit ≠ deploy.**

## 배포 체크리스트
```
1. 코드 변경 → git add → git commit
2. 🔴 git push origin master (자주 빼먹음)
3. Render/Netlify 자동 배포 대기
4. Deploys 페이지에서 Published 초록색 확인
5. PWA 앱 완전 종료 후 재시작 (캐시 갱신)
6. Web Push 관련 변경 시 → push_subscriptions 삭제 → 재구독
```
