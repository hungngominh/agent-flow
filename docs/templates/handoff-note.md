# Handoff Note — <YYYY-MM-DD> <session-id>
<!-- Fill all sections. Delete unused sections only if truly empty (e.g. no blockers). -->

## State Snapshot
- Active branch: `<branch-name or "none">`
- Current task: `<bd-id>` — `<status>`
- Last successful verification: `<CI run link | test report | "none yet">`

## Đã làm
<!-- List completed tasks with PR references -->
- `[bd-xxxx]` <task title> — DONE, PR #<n>
<!-- Add more lines as needed -->

## Dang dở
<!-- Tasks started but not finished -->
- `[bd-xxxx]` <task title> — IN PROGRESS
  Lý do chưa xong: <specific reason>
<!-- Add more lines as needed -->

## Blockers
<!-- Active blockers preventing progress -->
- `[bd-xxxx]` blocked: <specific reason, what is needed to unblock>
<!-- Remove this section if no blockers -->

## Nên làm tiếp
<!-- What the next session should pick up -->
- Run `bd ready` → will return `[bd-xxxx]` (<task title>)
- Context note: <any important context for next session>

## Spec / task đã update
<!-- Artifact sync status -->
- `<openspec/path>` → delta merged | confirmed no update needed
- Beads sync: `bd dolt push` ✅ | ⚠️ PENDING (reason: <reason>)

## Risks / Assumptions
<!-- Do not leave this blank if there is ANY uncertainty -->
- Assumption in use: <e.g., "Redis WATCH handles concurrent refresh correctly">
- Risk still open: <e.g., "Edge case X not tested under prod load">
- Not yet verified: <e.g., "Performance at 10k concurrent users">
