---
name: Palworld Modding Rules
description: User rules for Palworld mod creation workflow
type: feedback
originSessionId: 2419b334-5de5-430b-8b69-73403b706c3a
---
Always revert ALL changed files when a mod attempt fails or produces wrong results.
**Why:** User was frustrated when wrong BPs were modified and changes weren't cleaned up automatically.
**How to apply:** Any time a mod doesn't work as intended, immediately delete mod folders and remove entries from mods.txt before attempting a fix.

Never proceed with modding a skill without first confirming the exact internal BP class names.
**Why:** User was misled when I assumed "Eruption" BPs = 인페르노, which was wrong (Eruption = 화산 폭우, a completely different skill).
**How to apply:** Use pak binary search first: `grep -oa "BP_[A-Za-z0-9_]*SkillName[A-Za-z0-9_]*" Pal-Windows.pak`. This is faster, requires no game session, and is definitive. UE4SS log method only works if an existing mod already targets those BPs — do NOT rely on it as the primary discovery method.

Always look for the best available method before starting, not partway through.
**Why:** Used an inferior UE4SS log method from the start because it was already in use in the project, instead of exploring better alternatives first.
**How to apply:** Before beginning any research or discovery task, briefly consider what methods are available and pick the most direct one. Don't default to the existing approach without evaluating it.
