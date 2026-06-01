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
| **Self-deletes on restore** | ❌ | ❌ | ✅ |
| Treats repo/tracker as live truth | partial | ✅ | ✅ |

The self-delete is the whole point: a resume marker is only accurate at the instant it's written. Keeping it around past the next session's first re-orientation makes it a liability, not an asset. So `renew` writes one marker, the next session consumes it, and the workspace stays clean.

Pair it with a read-side resume skill: `renew` to **bank**, a resume skill to **rehydrate**.

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

## Configuration

- **Marker path:** defaults to `SESSION_RESUME.md` at the repo root. If your project keeps a memory index (e.g. `MEMORY.md`), the skill will use/refresh a single pointer there instead.
- **No external dependencies.** Pure markdown convention — no MCP server, no daemon, no DB.

## License

MIT.
