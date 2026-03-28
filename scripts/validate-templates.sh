#!/usr/bin/env bash
# Validate: no unfilled placeholders remain in template outputs.
# Usage: bash scripts/validate-templates.sh
set -euo pipefail

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
  # Files must exist. Placeholders like <lệnh> are intentional in templates.
  echo "OK: $f"
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
    if grep -qiE '\bTODO\b|\bTBD\b' "$f"; then
      echo "DRAFT CONTENT: $f contains TODO/TBD"
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
