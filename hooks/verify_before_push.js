#!/usr/bin/env node
/* ================================================================
   verify_before_push.js
   v234 사고 박제 — 무르 명시 승인 (2026-05-04)

   목적: git push 직전 메인/서브가 코드 분석 4섹션을 응답에 포함했는지 강제 검증
   1순위: 코드 분석 (현재 상태 / 의도 / 파생효과 / 적합 판단)
   2순위: Chrome MCP 시각 검증

   작동:
   - PreToolUse hook (Bash matcher) — git push 명령일 때만 발동
   - 가장 최근 transcript jsonl 의 마지막 assistant 메시지 검사
   - 4섹션 키워드 모두 있어야 통과 (exit 0)
   - 누락 시 exit 2 → push 차단 + stderr 메시지 Claude에 보임

   응급 우회: 무르가 직접 git push --no-verify  (사용자만)
   ================================================================ */

const fs = require('fs');
const path = require('path');
const os = require('os');

let stdin = '';
process.stdin.on('data', d => stdin += d);
process.stdin.on('end', () => {
  let payload;
  try { payload = JSON.parse(stdin); } catch (e) { process.exit(0); }

  const cmd = payload.tool_input?.command || '';
  // git push 명령만 대상 (우회 키워드: --no-verify, dry-run 등은 통과)
  if (!/^\s*git\s+(?:[-A-Za-z0-9_=:./"' ]*\s+)?push\b/.test(cmd)) process.exit(0);
  if (/--no-verify|--dry-run/.test(cmd)) process.exit(0);

  // 가장 최근 transcript jsonl 찾기
  const projDir = path.join(os.homedir(), '.claude', 'projects');
  let latest = null, latestMt = 0;
  try {
    for (const proj of fs.readdirSync(projDir)) {
      const pp = path.join(projDir, proj);
      let st;
      try { st = fs.statSync(pp); } catch { continue; }
      if (!st.isDirectory()) continue;
      for (const f of fs.readdirSync(pp)) {
        if (!f.endsWith('.jsonl')) continue;
        const fp = path.join(pp, f);
        const mt = fs.statSync(fp).mtimeMs;
        if (mt > latestMt) { latestMt = mt; latest = fp; }
      }
    }
  } catch (e) {
    // transcript 위치 못 찾으면 통과 (false positive 방지)
    process.exit(0);
  }
  if (!latest) process.exit(0);

  // 마지막 assistant 메시지 텍스트 모음 (최근 N개)
  const lines = fs.readFileSync(latest, 'utf8').split('\n').filter(Boolean);
  let lastText = '';
  let collected = 0;
  for (let i = lines.length - 1; i >= 0 && collected < 3; i--) {
    try {
      const obj = JSON.parse(lines[i]);
      if (obj.type === 'assistant' && obj.message?.content) {
        for (const c of obj.message.content) {
          if (c.type === 'text') lastText = c.text + '\n\n' + lastText;
        }
        collected++;
      }
    } catch (e) { /* skip */ }
  }

  // 4섹션 검사 (코드 분석 = 1순위 필수, 무르 v234 박제 + 정정)
  // 파생효과: 객관적·코드 기술적 카테고리 키워드만 매칭 (주관적 표현 X)
  const checks = [
    { name: '현재 상태', re: /현재\s*상태|\[측정\]|코드\s*상태|HTML|CSS|JS/ },
    { name: '의도', re: /의도|왜\s*이렇게|왜\s*만들|왜\s*변경|목적:|무르\s*원문|무르\s*요청/ },
    {
      name: '파생효과 (코드 기술적)',
      re: /dead\s*code|호출\s*변화|sessionStorage|localStorage|공유\s*클래스|absolute|overflow|공통\s*헬퍼|함수\s*영향|CSS\s*클래스|DB\s*컬럼|외래키|RLS|캐시\s*키|paged\(|sb\.from|영향받는\s*함수|영향받는\s*페이지|같은\s*클래스/
    },
    { name: '적합 판단', re: /적합\s*판단|일치|판단|0원칙|승인\s*받|0원칙\s*체크/ }
  ];
  const missing = checks.filter(c => !c.re.test(lastText));
  if (missing.length > 0) {
    console.error('');
    console.error('❌ git push 차단 — 코드 분석 4섹션 누락 (무르 v234 박제 강제)');
    console.error('');
    console.error('   누락 섹션: ' + missing.map(m => m.name).join(', '));
    console.error('');
    console.error('   직전 응답에 다음 4가지 모두 포함되어야 push 가능:');
    console.error('   (1) 현재 상태 — 코드가 지금 어떤 상태인지 (직접 Read 후 인용)');
    console.error('   (2) 의도 — 왜 이렇게 만들어졌는지 / 왜 이 변경을 하는지');
    console.error('   (3) 파생효과 — 이 변경이 어떤 다른 부분에 영향을 주는지');
    console.error('   (4) 적합 판단 — 무르 요청과 일치하는지 + 0원칙 체크 결과');
    console.error('');
    console.error('   응급 우회 (무르 명시 승인 시만): git push --no-verify');
    console.error('');
    process.exit(2);
  }

  // ──────────────────────────────────────────────────────────────────────
  // Phase H 추가 (옵션 1 엄격, 무르 명시 결정):
  // 직전 무르 메시지에 push 명시 키워드 (push/배포/올려/올려주/deploy/디플로이)
  // 없으면 차단. broad 해석 ("OK"/"진행" 등) 차단.
  // ──────────────────────────────────────────────────────────────────────
  // Phase H v244 fix: tool_result 도 type:'user' 로 기록됨 → 진짜 사용자 발화만 추출
  // tool_result 제외하고, type==='text' 인 메시지만 사용
  let lastUserText = '';
  for (let i = lines.length - 1; i >= 0; i--) {
    try {
      const obj = JSON.parse(lines[i]);
      if (obj.type !== 'user' || !obj.message?.content) continue;
      const c = obj.message.content;
      let text = '';
      if (typeof c === 'string') {
        text = c;
      } else if (Array.isArray(c)) {
        // type:'text' 만 (tool_result 등 제외)
        text = c.filter(x => x.type === 'text').map(x => x.text || '').join(' ');
      }
      if (text.trim()) {
        lastUserText = text;
        break;
      }
    } catch (e) { /* skip */ }
  }
  const userPushKwRe = /(push|배포|올려|올려주|deploy|디플로이)/i;
  if (!userPushKwRe.test(lastUserText)) {
    console.error('');
    console.error('❌ git push 차단 — 직전 무르 메시지에 push 명시 키워드 없음 (옵션 1 엄격)');
    console.error('');
    console.error('   인정 키워드: push / 배포 / 올려 / 올려주 / deploy / 디플로이');
    console.error('   직전 메시지 발췌: "' + lastUserText.slice(0, 120).replace(/\s+/g, ' ').trim() + '"');
    console.error('');
    console.error('   무르 명시 후 push, 또는 응급우회: git push --no-verify');
    console.error('');
    process.exit(2);
  }

  // 통과
  console.error('✅ 코드 분석 4섹션 + 무르 push 명시 검증 통과 — push 진행');
  process.exit(0);
});
