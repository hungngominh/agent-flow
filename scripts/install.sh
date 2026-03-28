#!/usr/bin/env bash
# install.sh — Bootstrap agent-flow framework in current project
# Usage: curl -sSL https://raw.githubusercontent.com/hungngominh/agent-flow/main/scripts/install.sh | bash

set -euo pipefail

REPO="https://raw.githubusercontent.com/hungngominh/agent-flow/main"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "🚀 agent-flow — Cài đặt AI Workflow Framework"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Tạo thư mục ──────────────────────────────────────────────────────────────
mkdir -p docs/templates docs/playbook scripts

# ── Download templates ────────────────────────────────────────────────────────
echo "📄 Tải templates..."
curl -sSL "$REPO/CLAUDE.md.template"              -o CLAUDE.md.template
curl -sSL "$REPO/docs/templates/beads-task.yaml"  -o docs/templates/beads-task.yaml
curl -sSL "$REPO/docs/templates/handoff-note.md"  -o docs/templates/handoff-note.md

# ── Download playbook ─────────────────────────────────────────────────────────
echo "📚 Tải playbook..."
for f in README.md 01-architecture.md 02-triage.md 03-flows.md \
          04-beads-guide.md 05-openspec-guide.md 06-quality-gates.md \
          07-handoff-protocol.md; do
  curl -sSL "$REPO/docs/playbook/$f" -o "docs/playbook/$f"
done

# ── Download validation script ────────────────────────────────────────────────
echo "🔍 Tải validation script..."
curl -sSL "$REPO/scripts/validate-templates.sh" -o scripts/validate-templates.sh
chmod +x scripts/validate-templates.sh

# ── Copy CLAUDE.md.template → CLAUDE.md ──────────────────────────────────────
if [ ! -f "CLAUDE.md" ]; then
  cp CLAUDE.md.template CLAUDE.md
  echo ""
  echo -e "${YELLOW}⚠️  CLAUDE.md đã được tạo — cần điền thông tin dự án:${NC}"
  echo "   Mở CLAUDE.md và thay tất cả <placeholder>"
else
  echo ""
  echo -e "${YELLOW}ℹ️  CLAUDE.md đã tồn tại — giữ nguyên, không ghi đè.${NC}"
fi

# ── Setup Beads hooks (nếu bd đã cài) ────────────────────────────────────────
if command -v bd &>/dev/null; then
  echo ""
  echo "🔗 Phát hiện Beads — chạy bd init + bd setup claude..."
  bd init 2>/dev/null || true
  bd setup claude 2>/dev/null || true
else
  echo ""
  echo -e "${YELLOW}ℹ️  Beads chưa cài. Để cài:${NC}"
  echo "   npm install -g @beads/bd && bd init && bd setup claude"
fi

# ── Setup OpenSpec (nếu openspec đã cài) ─────────────────────────────────────
if command -v openspec &>/dev/null; then
  echo ""
  echo "📋 Phát hiện OpenSpec — chạy openspec init..."
  openspec init 2>/dev/null || true
else
  echo ""
  echo -e "${YELLOW}ℹ️  OpenSpec chưa cài. Để cài:${NC}"
  echo "   npm install -g @fission-ai/openspec && openspec init"
fi

# ── Validation ────────────────────────────────────────────────────────────────
echo ""
echo "✅ Kiểm tra..."
bash scripts/validate-templates.sh 2>/dev/null | grep -E "^OK:" || true

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ agent-flow framework đã cài xong!${NC}"
echo ""
echo "Bước tiếp theo:"
echo "  1. Điền CLAUDE.md (thay tất cả <placeholder>)"
echo "  2. Đọc playbook: docs/playbook/README.md"
echo "  3. Superpowers: /install superpowers (trong Claude Code chat)"
echo ""
echo "Tài liệu: https://github.com/hungngominh/agent-flow"
echo ""
