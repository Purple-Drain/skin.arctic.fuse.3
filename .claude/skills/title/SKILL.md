---
name: title
description: Generate this thread's title line and print it, and nothing else. Fast path, no audit, no tool calls. Use when you just want the current title (e.g. for /rename). If it looks broken or stale, use title-fix.
---

# Thread title: generate on demand

Compose the title for the CURRENT thread right now and print it — nothing else.
No checklist recitation, no explanation. This is the cheap path for "give me
the line."

## Format

```
status emoji | dd.mm.yy | context emoji(s) | short title
```

Slot template, not literal syntax — no square brackets in the actual line;
the `|` above is the literal separator, with a space on each side.

## Composing it

Two parts, in order:

1. **Thread anchor** — the standing project/device/repo, NOT the current work
   topic. Pull this from this repo's CLAUDE.md project scope, or a device/repo
   name. Stable across the thread; only change it if the actual project/repo
   has changed. Never substitute the current task's subject here even if no
   other anchor is obvious — fall back to the repo/folder name before dropping
   the anchor.
2. **Current work** — the specific task in the latest exchange, a few words.
   This is where task-specific topics (e.g. "session strategy") belong — not
   in the anchor slot.

Join as `anchor: work`. Pick the status emoji for the state of the work (🟢
done/working, 🟡 in progress, 🔴 broken/blocked, 🔵 informational), and at
least one context emoji conveying the subject.

Before finalizing, check whether this turn leaves anything armed to act without
the user — an unfired `ScheduleWakeup`, a backgrounded `Workflow`/`CronCreate`,
or a background `Agent` call (`subagent_type: "fork"` or `isolation: "remote"`).
If so, add ⏳ to the context emoji; if the thread is fully at rest, leave it out.
This is independent of the status emoji choice — see this repo's `CLAUDE.md`
thread-title convention for why the two shouldn't be conflated.

If a session UUID for a hand-off/blocked/waiting relationship has already been
stated in this conversation's context (quoted in a notification, named by the
user), append its 8-hex prefix to the work slot in prose — `session 185a7b4e`.
Only when it's already stated — never go looking for one; that judgment call is
`title-fix`'s job, not this skill's fast path.

## Action

Invoked as `/title`: the entire response is the composed line, printed once. No
tool calls, no explanation, no list of checks (that is title-fix's job). A
one-line response is both the opening and closing title line, so the CLAUDE.md
convention is satisfied as-is.

If you're already mid-response and just need the closing/opening title (the
normal case), this is that: compose once, use it in both positions.
