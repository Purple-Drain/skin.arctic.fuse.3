---
name: title
description: Propose a session handoff title in this project's house format - status emoji, bracketed date, two topic emoji, repo, and the outcome. Use when the user asks to title a session, name it, close one out, wrap up, or asks what to call it.
---

# Session handoff title

Emit **one** title. Offer alternatives only when the framing is genuinely
ambiguous — for example when two repos both carry a durable outcome.

## Format

`<status> [DD.MM.YY] <two topic emoji> <repo>: <what actually happened>`

## Status emoji

| | meaning |
|---|---|
| 🟢 | landed — commits pushed, CI green |
| 🔵 | no repo change — investigation, diagnosis, or handoff only |
| 🟡 | landed, but something is unresolved or needs a follow-up |
| 🔴 | blocked or failed |

## Rules

- **Date** is today's, `DD.MM.YY`, in brackets. Older notes are inconsistent
  about the brackets; standardise on them.
- **Repo** is the one carrying the durable outcome. If the work spanned several,
  pick the one a future session would grep first.
- **The tail states the outcome, not the activity.** "clones synced, no leftover
  to PR" beats "worked on syncing clones".
- **Never claim a push, a merge, or green CI that wasn't verified in-session.**
  This is the rule most worth keeping — these repos' own handoff notes carry
  corrections where exactly that went wrong. If CI was not observed, 🟡 or 🔵
  is the honest status, not 🟢.
- Two topic emoji, chosen for the subject.

## Examples

Real titles from these repos:

    🟢 [02.08.26] 📤🛡️ kodi-strm-pipeline: pushed and closed, CI green
    🔵 [29.07.26] 🎬🔧 kodi-shield-config: confirmed Dolby Vision is currently ON
    🟢 [28.07.26] ⚽📺 kodi-shield-config: Winter Festival of Football added
    🟢 [02.08.26] 🛡️🔗 kodi-shield-config: clones synced, no leftover to PR

---

**This file has three identical siblings.** The same skill is committed in
`kodi-strm-pipeline`, `kodi-shield-config`, `skin.arctic.fuse.3` and
`shield-debug-toolkit`, so a cloud session gets it whichever repo it clones —
`~/.claude/` does not travel to remote sessions, only the repo does. Deliberately
copied rather than symlinked: the `kodi-log` symlink pattern works only while the
repos are siblings on one disk, and its `skillOverrides` live in a gitignored
`.claude/settings.local.json`. Edit one copy, sync the other three.
