---
name: renew
description: "Use when ending a working session, before /clear or /compact, when starting a fresh session to continue prior work, or when the user says 'renew', 'bank the session', 'leave a marker', 'save a resume point', or 'new session'. Banks the session into a one-shot, self-deleting resume marker (a BATON) so the next session resumes with zero ramp-up."
---

# renew — Session Resume Baton

Author a tight, distilled marker at session end so the next session resumes instantly, then hand off a baton that **deletes itself on restore**. The repo, version control, and your issue tracker are the live truth — the marker only bootstraps.

## When to use
- End of a working session, before `/clear` or `/compact`, or "let's start a new session."
- The user says `renew`, "bank the session," "leave a marker," "save a resume point."
- **Also at the START of a fresh session** when a marker already exists — read it, restore, then delete it (see step 4).

## Where the marker lives
Default to a single, predictable path at the repo root: **`SESSION_RESUME.md`**.

- If your agent has a project memory/notes directory, you may place it there instead (e.g. a `MEMORY.md`-indexed memory dir). Match an existing marker's path if one is already present.
- One marker per project. **Overwrite** it on every `renew` — never accumulate `resume-001`, `resume-002`.

## 1. Synthesize the resumable state
Don't dump the transcript — distill what the next session actually needs:
- **▶️ Immediate next action** — the ONE thing to do next, with exact repo / branch / file paths / commands.
- **Shipped & live this session** — what's done and where (commit SHAs, PR numbers, deploy status).
- **In-flight / needs verification** — partial work, what's unproven, who owns it.
- **Open / pending** — queued items, blockers, decisions awaiting the user.
- **Gotchas** — non-obvious env / deploy / ownership facts that would trip a fresh session.

Convert relative dates to absolute. Keep it scannable.

## 2. Write the marker
Overwrite `SESSION_RESUME.md` (or your matched path) with:

```markdown
---
title: SESSION RESUME — <one-line state + next action>
snapshot: <absolute-date>
baton: true   # ⚠️ Once restored, DELETE this file. It goes stale fast; the repo + tracker are the live truth.
---

> 🧹 On restore: after you've read this and re-oriented, DELETE this file (and any index pointer to it). It only bootstraps the next session.

## ▶️ Next action
...

## Shipped & live this session
...

## In-flight / needs verification
...

## Open / pending
...

## Gotchas
...
```

## 3. (Optional) Index it
If your project keeps a memory index (e.g. `MEMORY.md`), add or refresh a **single** top pointer:
```
- ▶️ [Session resume](SESSION_RESUME.md) — START HERE on a new session: <state + next action>
```
Replace any prior pointer — never stack two. Skip this step entirely if there's no index.

## 4. Consumption protocol (what makes it a baton, not clutter)
The marker reflects a moment in time and rots quickly. Therefore, **at the START of the next session**:
1. Read the marker and restore context.
2. Re-orient against live truth — `git status`, branch, open PRs/issues, and any project orient/standup step.
3. **DELETE the marker file** and remove its index pointer (if any).

The marker's own frontmatter and `🧹 On restore` note must state this, so any agent that reads it knows to clean up.

## Don't
- Don't write the whole transcript — synthesize the *resumable* state.
- Don't duplicate what the repo / tracker already surfaces — capture the non-obvious (next action, decisions, gotchas).
- Don't leave stale markers — overwrite on each `renew`; the marker self-instructs deletion on restore.
- Don't accumulate multiple markers or stack index pointers.
- Don't trust the marker over the working tree — if it conflicts with current files, the files win; note the discrepancy.

## Relationship to other skills
`renew` is self-contained: it authors the baton AND the baton carries its own restore-and-delete instructions (step 4), so the next session consumes it with no other skill loaded. Read-side resume skills (e.g. `agent-session-resume`) address the *opposite* condition — reconstructing context when no deliberate marker exists, by scavenging native transcripts/exports. If you ran `renew`, you don't need them; if you didn't, they're the fallback.
