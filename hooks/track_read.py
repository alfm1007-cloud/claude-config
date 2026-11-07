#!/usr/bin/env python3
"""
PostToolUse(Read) hook — 읽은 파일 경로+시각을 세션 트래커에 기록
tracker: /tmp/claude_read_tracker.txt  (라인: epoch TAB filepath)
"""
import os, json, time

TRACKER = '/tmp/claude_read_tracker.txt'

d  = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
fp = d.get('file_path', '')

if fp:
    fp = os.path.abspath(os.path.expanduser(fp))
    with open(TRACKER, 'a') as f:
        f.write(f'{time.time():.0f}\t{fp}\n')
