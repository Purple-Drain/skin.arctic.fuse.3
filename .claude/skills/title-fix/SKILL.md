---
name: title-fix
description: Audit and repair a thread-title line against the full checklist. Use when the title looks broken, missing, or stale after a topic shift, not for routine generation (use title for that).
---

# Thread title: audit and repair

The governing rule is in this repo's `CLAUDE.md`. This skill is the manual,
full-checklist repair path for when that rule has visibly not been followed —
malformed, missing, or stale. For routine "just give me the title" generation,
use the `title` skill instead; this one is for diagnosing and fixing a problem.

No local hook enforces this convention in cloud or background sessions — there
is nothing that will nudge you automatically, so run this checklist yourself
whenever a title looks off, and don't assume silence means it passed.

## The format

```
status emoji | dd.mm.yy | context emoji(s) | short title
```

Slot template, not literal syntax — no square brackets in the actual line;
the `|` above is the literal separator, with a space on each side.

Every response must **begin and end** with exactly one such line. Nothing
before the first one, nothing after the last one — including any narration
you write before a tool call; the title must be the true first line of the
whole response, not just of a later text block.

## Checklist

Run each against the most recent response and report which ones fail:

1. **Present twice** — first line and last line, both.
2. **Status emoji is an actual emoji** — never the literal word "Status", never
   a label like `Status: 🟢`.
3. **Date is `dd.mm.yy`** — day-first order. `17.07.26`, not `07.17.26` and
   not `2026-07-17`.
4. **At least one context emoji** after the date, conveying the subject.
5. **Pending-autonomy marker (⏳) is correct** — present iff this turn actually left something
   armed to act without the user: an unfired `ScheduleWakeup` (no `stop: true`), a backgrounded
   `Workflow`/`CronCreate`, or a background `Agent` call (`subagent_type: "fork"` or
   `isolation: "remote"`). Absent when the thread is fully at rest. Check the turn's own tool
   calls, not a guess.
6. **Cross-session reference, when one is explicit, is present and short** — if this thread's
   conversation context explicitly states it hands off to, is blocked on, or is waiting on
   another session (not "might be relevant" — actually said, e.g. the UUID was quoted in a
   notification or named by the user), the work slot names that session by its 8-hex UUID
   prefix (`session 185a7b4e`) — not a new bracketed field. Absent when no such relationship is
   explicit; don't invent one from a loose association.
7. **Title is short** — a few words, not a sentence.
8. **No prefix, no label, no literal brackets** — no "Suggested thread title:",
   no bolding, no backticks, no trailing commentary after the final line, and
   no literal `[` `]` characters either — the format is a slot template, not
   bracket syntax.
9. **Topic still matches** — the title should only change when the subject
   materially shifts, so a title that no longer describes the thread is stale
   even if the format is perfect.
10. **Covers thread + current work, not just the last message** — the title
   names the overarching subject of the thread (project/device/domain) *and*,
   where it fits in a few words, what's actively being worked. A title that
   only describes the most recent reply loses the thread the moment the topic
   moves on to the next task within it.

## Composing the corrected title

Two parts, in order:

1. **Thread anchor** — the standing subject: project name, device, repo. This
   is what this repo's CLAUDE.md project scope already tells you. Stays stable
   across most of the thread.
2. **Current work** — the specific task in the latest exchange: a fix, a
   question, a decision. Changes response to response.

Join tersely — `anchor: work`. Don't restate the whole thread history; the
anchor is one or two words, not a recap.

- Weak (work only, loses the thread): `🟢 20.07.26 🌐🔧 Branch fix`
- Better (anchor + work): `🟢 20.07.26 📡🔧 device-name: branch fix`
- Weak (anchor only, stale once work moves on): `🔵 20.07.26 📡 device-name tuning`
- Better once the work is a specific change: `🟡 20.07.26 📡📶 device-name: 2.4GHz test`

Only rewrite the anchor when the thread's actual subject changes (check 9).
Update the "current work" half more freely.

## Status emoji vocabulary

- 🟢 done, working, verified
- 🟡 in progress, partial, awaiting input
- 🔴 broken, blocked, failing
- 🔵 informational, reference, discussion

## Pending-autonomy marker

⏳ answers a different question than the status emoji: not "how did the work go"
but "will anything happen here without the user typing." Use it whenever this
turn leaves something armed — a scheduled wakeup, a background agent/workflow
still running, an active cron — and omit it when the thread is genuinely idle.
A 🟢 thread can still be unsafe to walk away from (a background task not yet
reported back); a 🟡 thread can be perfectly safe (just waiting on a wakeup).
Don't infer one from the other.

## Cross-session references

Answers a different question than the anchor or the ⏳ marker: not "what session is this" but
"does this session's fate depend on another one." Only add it when context makes the
relationship explicit — a notification quoted another session's UUID, or the user named one.
Never run a discovery step to go find a UUID to cite just for the title — that turns a cheap
title composition into an investigation, which is out of scope here.

Format: the 8-hex prefix of the other session's UUID, in the work slot, in prose —
`repo-name: blocked on session 185a7b4e` — not a bracketed field and not the full 36-char
UUID (defeats the point of keeping titles short).

## Action

State plainly which checks failed and why, then re-issue the corrected title
in both positions in your response. Do not just describe the fix — apply it.
If every check passes, say so in one line and keep the existing title
unchanged.
