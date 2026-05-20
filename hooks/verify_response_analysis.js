#!/usr/bin/env node
/* ================================================================
   verify_response_analysis.js
   Stop hook — 매 응답(turn) 종료 시 발동

   목적: 무르 0원칙 #1 (현재 상황 + 무르 본질) 매 응답 자가검토 강제
   메커니즘: 외부 Anthropic API (Haiku) 로 검수 에이전트 호출
            → 응답에 본질 파악 / 분석 근거 흔적 있나 Y/N 판정
            → N 이면 stderr 로 환기 (다음 turn system-reminder)

   토큰 분리: 무르 platform.claude.com 잔액에서만 차감
            (현재 Claude Code 세션 토큰 영향 X)

   조건부 발동: 단답/실행 지시는 검수 X (토큰 효율)
   ================================================================ */

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');
const { execSync } = require('child_process');

const MODEL = 'claude-haiku-4-5';

// API 키 인출 — process.env 우선, 없으면 PowerShell fallback (Windows User env)
// (Claude Code Bash 셸이 Windows User env 자동 상속 안 하는 케이스 대응)
let API_KEY = process.env.ANTHROPIC_API_KEY;
if (!API_KEY && process.platform === 'win32') {
  try {
    API_KEY = execSync(
      `powershell.exe -NoProfile -Command "[Environment]::GetEnvironmentVariable('ANTHROPIC_API_KEY', 'User')"`,
      { encoding: 'utf8', timeout: 3000 }
    ).trim();
  } catch (e) {}
}

// API 키 없으면 silent skip (등록 전 무해)
if (!API_KEY) {
  console.error('[verify_response_analysis] ANTHROPIC_API_KEY 미등록 — 검수 skip');
  process.exit(0);
}

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
} catch (e) { process.exit(0); }
if (!latest) process.exit(0);

// 마지막 user 메시지 + 마지막 assistant 응답 추출
const lines = fs.readFileSync(latest, 'utf8').split('\n').filter(Boolean);
let lastUserText = '';
let lastAssistantText = '';

for (let i = lines.length - 1; i >= 0; i--) {
  try {
    const obj = JSON.parse(lines[i]);
    if (!lastAssistantText && obj.type === 'assistant' && obj.message?.content) {
      for (const c of obj.message.content) {
        if (c.type === 'text') lastAssistantText = c.text + '\n' + lastAssistantText;
      }
    }
    if (!lastUserText && obj.type === 'user' && obj.message?.content) {
      const c = obj.message.content;
      lastUserText = typeof c === 'string' ? c : c.map(x => x.text || x.content || '').join(' ');
    }
    if (lastUserText && lastAssistantText) break;
  } catch (e) {}
}
if (!lastUserText || !lastAssistantText) process.exit(0);

// 단답/실행 지시는 검수 skip — 토큰 효율
// 분석/원인/이유/추천/비교/평가/메타 키워드 있을 때만 발동
const complexKw = /분석|원인|이유|왜|어떻|어느|추천|비교|평가|차이|장단|개선|문제점|대안|설명|메커니즘|구조|효과|효율|한계/;
if (!complexKw.test(lastUserText)) {
  // 단답 — 검수 skip
  process.exit(0);
}

// 응답 길이 짧으면 skip (단순 확인 등)
if (lastAssistantText.length < 200) process.exit(0);

// ──────────────────────────────────────────────────────────────────────
// A안 1차: 응답 첫 줄 형식 마커 정규식 검사 (무르 v239 박제 강제)
// 강제 형식: [현재 상황: ___ / 무르 본질: ___ / 승인: Y/N]
// 누락 시 stderr 환기 — Haiku 호출은 이어서 (형식 채우기 잡음)
// ──────────────────────────────────────────────────────────────────────
const firstLines = lastAssistantText.split('\n').slice(0, 3).join('\n');
const formatMarkerRe = /\[\s*현재\s*상황\s*:.*\/.*무르\s*본질\s*:.*\/.*승인\s*:\s*[YN]/i;
const formatMarkerPresent = formatMarkerRe.test(firstLines);
if (!formatMarkerPresent) {
  console.error('');
  console.error('⚠️  A안 1차 (형식 마커) — 응답 첫 줄 강제 형식 누락');
  console.error('   필요: [현재 상황: ___ / 무르 본질: ___ / 승인: Y/N]');
  console.error('   현재 첫 줄: ' + (lastAssistantText.split('\n')[0] || '').slice(0, 80));
  console.error('');
  // 1차 누락이어도 Haiku 검수는 이어 진행 — 내용 자체 검증
}

// 검수 에이전트 시스템 프롬프트 (A안 통합 — 형식 + 내용 동시 검수)
const systemPrompt = `당신은 0원칙 자가검토 검수 에이전트입니다.
사용자(무르)의 0원칙: "현재 상황 파악 + 분석 후 답변. 표면 키워드 X, 본질 파악 O."

다음 응답을 두 측면에서 판정합니다:

[측면 1 — 응답 첫 줄 형식 마커]
강제 형식: [현재 상황: ___ / 무르 본질: ___ / 승인: Y/N]
- 마커 자체 존재 여부
- 각 칸이 빈 칸 또는 형식 채우기로 채워졌는지 (예: "확인함", "OK" 같은 무의미 채움)
- 진짜 분석 흔적이 있는지

[측면 2 — 본문 내용]
- 무르 본질을 정면 답변했는가 (표면 질문 ≠ 본질 분리)
- 근거 인용/구체 디테일/측정 라벨 있는가
- 단정어, 거짓·축소 표현, 박제·룰 회피, 변명·자기합리화 없는가

판정:
- Y: 형식 마커 진정성 + 본문 본질 답변 둘 다 OK
- N: 둘 중 하나라도 부재/형식 채우기/표면 답변

응답 형식 (반드시 첫 글자):
Y — <간단 사유 1줄>
또는
N — <측면1 또는 측면2 누락 명시 + 환기 메시지 1~2줄>`;

const userPrompt = `[무르 발화]
${lastUserText.slice(0, 2000)}

[직원(Claude) 응답]
${lastAssistantText.slice(0, 4000)}`;

const body = JSON.stringify({
  model: MODEL,
  max_tokens: 200,
  system: systemPrompt,
  messages: [{ role: 'user', content: userPrompt }]
});

const req = https.request({
  hostname: 'api.anthropic.com',
  path: '/v1/messages',
  method: 'POST',
  headers: {
    'x-api-key': API_KEY,
    'anthropic-version': '2023-06-01',
    'content-type': 'application/json',
    'content-length': Buffer.byteLength(body)
  },
  timeout: 8000
}, res => {
  let data = '';
  res.on('data', d => data += d);
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      const verdict = json.content?.[0]?.text || '';
      // N 이면 stderr 로 환기 (다음 turn system-reminder)
      if (verdict.trim().startsWith('N')) {
        console.error('');
        console.error('⚠️  검수 에이전트 판정: N (자가검토 누락)');
        console.error('   ' + verdict.replace(/^N\s*[—\-:]\s*/, '').trim());
        console.error('');
        console.error('   다음 응답에서 본질 파악·분석 근거 보강 필요.');
        console.error('');
      }
      // Y 면 silent (무르 알림 X — 토큰 효율)
    } catch (e) {
      // 파싱 실패 silent skip
    }
    process.exit(0);
  });
});

req.on('error', () => process.exit(0));
req.on('timeout', () => { req.destroy(); process.exit(0); });
req.write(body);
req.end();
