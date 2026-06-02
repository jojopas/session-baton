#!/bin/sh
# session-baton — SessionStart hook (the READ side of `renew`)
#
# Purpose: kill the "now tell me to continue" step. When a `renew` baton
# marker exists, this hook injects it into the FRESH session as context, so
# the next session restores itself with zero prompting — you just type
# `/clear` and keep going.
#
# Why this works: Claude Code adds a SessionStart hook's plain stdout to the
# new session's context, and SessionStart fires on `/clear`. So the full flow
# becomes two keystrokes:
#
#     /renew      → bank the session into a one-shot marker
#     /clear      → fresh session; THIS hook injects the marker; the session
#                   restores, re-orients, and DELETES the baton on its own.
#
# The marker is a BATON, not a log: it bootstraps the next session and then
# self-deletes. This hook only emits when a marker is present, so a normal
# startup with no baton is a silent no-op.
#
# Pure POSIX shell. No dependencies — no jq, no python, no daemon.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
MARKER=""

# 1) Repo-root convention (session-baton default).
if [ -f "$PROJECT_DIR/SESSION_RESUME.md" ]; then
  MARKER="$PROJECT_DIR/SESSION_RESUME.md"
fi

# 2) Claude Code auto-memory-dir convention (optional): some setups write the
#    marker into the project's memory dir as `<project>-session-resume.md` and
#    index a one-line pointer in MEMORY.md. The memory dir is
#    ~/.claude/projects/<project-path-with-slashes-as-dashes>/memory.
#    On any other agent this glob simply won't match — harmless.
if [ -z "$MARKER" ]; then
  slug=$(printf '%s' "$PROJECT_DIR" | sed 's:/:-:g')
  mem_dir="$HOME/.claude/projects/$slug/memory"
  for f in "$mem_dir"/*-session-resume.md; do
    [ -f "$f" ] && MARKER="$f" && break
  done
fi

# No baton → nothing to do.
[ -z "$MARKER" ] && exit 0

cat <<EOF
🔄 SESSION BATON DETECTED — a \`renew\` resume marker is present. This is a
one-shot handoff from your previous session, not a permanent doc.

Before addressing the user's request:
  1. Read the marker below — it is your restore point (next action, what
     shipped, what's in-flight, gotchas).
  2. Re-orient against live truth: \`git status\`, current branch, open
     PRs/issues. If the marker conflicts with the working tree, the tree wins.
  3. Then DELETE the baton so it can't go stale — do this silently, without
     asking; it is the documented baton contract:
        • remove the file: $MARKER
        • remove its one-line pointer in MEMORY.md, if one exists.
  4. Pick up at the ▶️ next action.

----- BEGIN SESSION BATON ($MARKER) -----
EOF
cat "$MARKER"
cat <<'EOF'

----- END SESSION BATON -----
EOF
exit 0
