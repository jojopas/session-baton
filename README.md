# renew — a self-deleting session baton for coding agents

`renew` banks your current AI coding-agent session into **one** distilled resume marker, so the next session picks up with zero ramp-up. The twist: the marker is a **baton, not a log** — once the next session reads it and re-orients against the live repo, it **deletes itself**.

## Why another session skill?

Most session-continuity tools fall into two camps:

- **Read-side / resume skills** (e.g. [`agent-session-resume`](https://github.com/hacktivist123/agent-session-resume)) reconstruct context from whatever native transcripts, exports, or compact summaries already exist.
- **Handoff skills** generate a checkpoint doc — but they *accumulate*: `handoff-001`, `handoff-002`, a growing trail of files that rot.

`renew` is the missing **write side with cleanup**:

| | Handoff skills | `agent-session-resume` | **renew** |
|---|---|---|---|
| Authors a deliberate, distilled marker | ✅ | ❌ (reads existing) | ✅ |
| Distills (not raw transcript) | ✅ | partial | ✅ |
| **Overwrites — one marker, never a trail** | ❌ (accumulates) | n/a | ✅ |
| **Self-delete contract, explicit** † | ❌ | ❌ | ✅ |
| Treats repo/tracker as live truth | partial | ✅ | ✅ |

† Capable models often self-delete an obvious one-shot marker anyway; `renew` makes the cleanup an explicit, reliable contract rather than relying on that instinct.

The real value is on the **write side**: one *distilled* marker (next action, what shipped, what's in-flight, gotchas) — verified against `git`, not a transcript dump — that **overwrites** instead of piling up a trail of stale handoff files. The self-delete contract is written into the marker so cleanup is *explicit and reliable* rather than left to the model's judgment.

> **Tested honesty:** in subagent trials, capable models actually self-delete a file obviously named `SESSION_RESUME.md` *without* this skill — the baton instinct is partly emergent. `renew` earns its keep by (a) standardizing the *write* (distill, verify SHAs, overwrite-one) and (b) guaranteeing the cleanup contract on weaker/cheaper models that won't self-clean. It's a discipline + convention, not a magic trick.

`renew` is **self-contained** — the marker carries its own restore-and-delete instructions, so the next session reads it and continues with no other skill loaded. Read-side scavenger skills like [`agent-session-resume`](https://github.com/hacktivist123/agent-session-resume) solve the *opposite* starting condition: reconstructing context when no deliberate marker was left (digging through native transcripts, exports, compact summaries). If you ran `renew` last session, you don't need them.

## Install

Copy `skills/renew/` into your agent's skills directory:

- **Claude Code:** `~/.claude/skills/renew/`
- **Codex:** `~/.agents/skills/renew/`
- Or install the whole repo as a plugin if your agent supports it.

## Use

End of a session, or before `/clear`:

```
/renew
```

or just say "bank the session" / "leave a resume marker."

It writes `SESSION_RESUME.md` at the repo root. Next session, the marker bootstraps you back in — then gets deleted.

## Auto-resume (optional hook) — the fast path

The skill alone is the *write* side: `/renew` banks the marker. On its own, the next session still has to notice the marker and act on it — so the flow is `/renew` → `/clear` → "ok, continue." That last nudge is the friction.

The bundled **`SessionStart` hook** removes it. It injects the marker into the fresh session automatically, so the session restores, re-orients, and deletes the baton with no prompting:

```
/renew     → bank the session into the marker
/clear     → fresh session auto-restores from the marker, then deletes it
```

Two keystrokes. `/clear` itself can't be automated — **no agent can clear its own context** (there is no tool, command, or hook that resets the conversation mid-turn; `/clear` is user-only). The hook automates everything *after* the clear.

### Install the hook (Claude Code)

1. Copy the hook somewhere stable, e.g.:
   ```sh
   mkdir -p ~/.claude/hooks
   cp hooks/session-start.sh ~/.claude/hooks/session-baton-resume.sh
   chmod +x ~/.claude/hooks/session-baton-resume.sh
   ```
2. Register it as a `SessionStart` hook in `~/.claude/settings.json` (add to the existing array if you already have SessionStart hooks):
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "matcher": "",
           "hooks": [
             { "type": "command", "command": "~/.claude/hooks/session-baton-resume.sh", "timeout": 5 }
           ]
         }
       ]
     }
   }
   ```

How it works: Claude Code adds a `SessionStart` hook's stdout to the new session's context, and `SessionStart` fires on `/clear` (and its aliases `/new` and `/reset`, all `source: "clear"`). The hook prints the marker only when one exists — otherwise it's a silent no-op, so ordinary startups are unaffected.

## Configuration

- **Marker path:** defaults to `SESSION_RESUME.md` at the repo root. The hook also finds the Claude Code auto-memory-dir variant (`<memory-dir>/<project>-session-resume.md`) if your setup writes the marker there and indexes it in `MEMORY.md`.
- **No external dependencies.** Pure markdown convention plus an optional pure-shell hook — no MCP server, no daemon, no DB, no `jq`/`python`.

## License

MIT.
