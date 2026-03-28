#!/usr/bin/env bash
# Validate: framework files exist and contain no draft (TODO/TBD) content.
# Usage: bash scripts/validate-templates.sh
set -euo pipefail
cd "$(dirname "$0")/.."

ERRORS=0
FILES=(
  "CLAUDE.md.template"
  "docs/templates/beads-task.yaml"
  "docs/templates/handoff-note.md"
)

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "MISSING: $f"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  # Fail if any template file contains TODO or TBD (we don't want draft content shipped)
  matches=$(grep -niE '\bTODO\b|\bTBD\b' "$f" || true)
  if [ -n "$matches" ]; then
    echo "DRAFT CONTENT: $f"
    echo "$matches" | sed 's/^/  /'
    ERRORS=$((ERRORS + 1))
  else
    echo "OK: $f"
  fi
done

# Check playbook files exist
PLAYBOOK=(
  "docs/playbook/README.md"
  "docs/playbook/01-architecture.md"
  "docs/playbook/02-triage.md"
  "docs/playbook/03-flows.md"
  "docs/playbook/04-beads-guide.md"
  "docs/playbook/05-openspec-guide.md"
  "docs/playbook/06-quality-gates.md"
  "docs/playbook/07-handoff-protocol.md"
)

for f in "${PLAYBOOK[@]}"; do
  if [ ! -f "$f" ]; then
    echo "MISSING: $f"
    ERRORS=$((ERRORS + 1))
  else
    # Fail if any playbook file contains TODO or TBD (we don't want draft content shipped)
    matches=$(grep -niE '\bTODO\b|\bTBD\b' "$f" || true)
    if [ -n "$matches" ]; then
      echo "DRAFT CONTENT: $f"
      echo "$matches" | sed 's/^/  /'
      ERRORS=$((ERRORS + 1))
    else
      echo "OK: $f"
    fi
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "FAIL: $ERRORS issue(s) found."
  exit 1
fi
echo ""
echo "PASS: all framework files present and clean."
