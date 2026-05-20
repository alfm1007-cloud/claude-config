#!/usr/bin/env python3
"""
PreToolUse 훅 — Edit/Write 실행 전 현재 파일 상태 강제 출력
하이브리드 D방식:
  - 30KB 미만: 전체 구조 출력 (설정/유틸 파일)
  - 30KB 이상: Edit 대상 부근 ±30줄만 출력 (비즈니스 로직 파일)
"""
import os
import json
import sys
import re

THRESHOLD = 30 * 1024  # 30KB
PATTERNS = {
    'js':   re.compile(r'(function\s|const\s|async function|=>[\s{])'),
    'html': re.compile(r'(function\s|const\s|id="|data-action=)'),
}

d = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
fp       = d.get('file_path', '')
old_str  = d.get('old_string', '')

if not fp:
    sys.exit(0)

if not os.path.isfile(fp):
    print(f'=== 새 파일 생성 예정: {fp} ===')
    sys.exit(0)

size    = os.path.getsize(fp)
ext     = fp.rsplit('.', 1)[-1].lower() if '.' in fp else ''
bname   = os.path.basename(fp)

print(f'\n{"="*60}')
print(f'[PreEdit] {bname}  ({size:,}B / {size//1024}KB)')
print(f'{"="*60}')

try:
    with open(fp, encoding='utf-8', errors='ignore') as f:
        content = f.read()
    lines = content.splitlines()

    # ── 30KB 미만: 전체 구조 ──────────────────────────────
    if size < THRESHOLD:
        print('[전체 구조]')

        if ext == 'json':
            print(content[:3000])

        elif ext in ('js', 'html'):
            pat = PATTERNS.get(ext)
            matched = [(i+1, l) for i, l in enumerate(lines) if pat and pat.search(l)]
            if matched:
                out = '\n'.join(f'{no:4d}  {l}' for no, l in matched[:80])
                print(out)
            else:
                print(content[:2000])

        else:  # md, css, txt 등
            print(content[:2000])

    # ── 30KB 이상: 변경 부근 ±30줄 ──────────────────────
    else:
        print('[큰 파일 — Edit 대상 부근 ±30줄]')

        found = -1
        if old_str:
            target = old_str.split('\n')[0].strip()[:80]  # 첫 줄로 위치 탐색
            for i, line in enumerate(lines):
                if target and target in line:
                    found = i
                    break

        if found >= 0:
            start = max(0, found - 30)
            end   = min(len(lines), found + 31)
            print(f'(L{start+1}~L{end}  |  수정 위치: L{found+1})\n')
            for i in range(start, end):
                marker = ' >>>' if i == found else '    '
                print(f'{i+1:4d}{marker}  {lines[i]}')

        else:
            # 위치 탐색 실패 → 함수 구조 fallback
            print('(Edit 위치 탐색 실패 — 함수 구조 fallback)')
            pat = PATTERNS.get(ext)
            if pat:
                matched = [(i+1, l) for i, l in enumerate(lines) if pat.search(l)]
                out = '\n'.join(f'{no:4d}  {l}' for no, l in matched[:60])
                print(out if out else '(패턴 없음)')
            else:
                print(content[:1500])

except Exception as e:
    print(f'(오류: {e})')

print(f'{"="*60}\n')
sys.exit(0)
