
## Heading style

No generic label headings: "The Problem", "The Solution", "The Overview", "Key
Takeaways", "Conclusion". A heading says what its section says, in two to four specific
words ("Why the sync failed", "Worktree setup"). Headings are earned: none in a response
under about 500 words, at most three above it. Structural headings in templates (handoff
notes, decision records) are exempt. Ported from Purple-Drain/claude-tools#376 so cloud
sessions that only see this repo follow it too.

## Thread title convention

Begin and end every response with exactly this line — nothing before, nothing after:

`status emoji | dd.mm.yy | context emoji(s) | anchor: work`

(Slot template, not literal syntax — no square brackets in the actual line; the `|`
above is the literal separator, with a space on each side.)

Status: 🟢 done · 🟡 in progress · 🔴 blocked · 🔵 informational. Dates are day-first
(`04.08.26`). Anchor is the standing project/repo, then the current task in a few words.
Change the title only when the topic materially shifts. Add ⏳ to the context emoji if
this turn leaves anything armed to run without the user (a scheduled wakeup, background
agent, or cron); leave it off otherwise.

Composition → `title` skill. Full checklist and repair → `title-fix` skill. Both live in
this repo's `.claude/skills/`. No local hook enforces this in cloud or background
sessions, so hold yourself to the checklist directly rather than waiting to be told.
