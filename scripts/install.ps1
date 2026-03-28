# install.ps1 — Bootstrap agent-flow framework in current project (Windows)
# Usage: irm https://raw.githubusercontent.com/hungngominh/agent-flow/main/scripts/install.ps1 | iex

$ErrorActionPreference = "Stop"
$REPO = "https://raw.githubusercontent.com/hungngominh/agent-flow/main"

function Download-File($url, $dest) {
    $dir = Split-Path $dest -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

Write-Host ""
Write-Host "🚀 agent-flow — Cài đặt AI Workflow Framework" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# ── Tạo thư mục ──────────────────────────────────────────────────────────────
New-Item -ItemType Directory -Path "docs\templates" -Force | Out-Null
New-Item -ItemType Directory -Path "docs\playbook"  -Force | Out-Null
New-Item -ItemType Directory -Path "scripts"         -Force | Out-Null

# ── Download templates ────────────────────────────────────────────────────────
Write-Host "📄 Tải templates..."
Download-File "$REPO/CLAUDE.md.template"             "CLAUDE.md.template"
Download-File "$REPO/docs/templates/beads-task.yaml" "docs\templates\beads-task.yaml"
Download-File "$REPO/docs/templates/handoff-note.md" "docs\templates\handoff-note.md"

# ── Download playbook ─────────────────────────────────────────────────────────
Write-Host "📚 Tải playbook..."
$playbooks = @(
    "README.md", "01-architecture.md", "02-triage.md", "03-flows.md",
    "04-beads-guide.md", "05-openspec-guide.md", "06-quality-gates.md",
    "07-handoff-protocol.md"
)
foreach ($f in $playbooks) {
    Download-File "$REPO/docs/playbook/$f" "docs\playbook\$f"
}

# ── Download validation script ────────────────────────────────────────────────
Write-Host "🔍 Tải validation script..."
Download-File "$REPO/scripts/validate-templates.sh" "scripts\validate-templates.sh"

# ── Copy CLAUDE.md ────────────────────────────────────────────────────────────
if (-not (Test-Path "CLAUDE.md")) {
    Copy-Item "CLAUDE.md.template" "CLAUDE.md"
    Write-Host ""
    Write-Host "⚠️  CLAUDE.md đã được tạo — cần điền thông tin dự án:" -ForegroundColor Yellow
    Write-Host "   Mở CLAUDE.md và thay tất cả <placeholder>" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "ℹ️  CLAUDE.md đã tồn tại — giữ nguyên, không ghi đè." -ForegroundColor Yellow
}

# ── Setup Beads (nếu bd đã cài) ───────────────────────────────────────────────
if (Get-Command bd -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "🔗 Phát hiện Beads — chạy bd init + bd setup claude..."
    bd init 2>$null; bd setup claude 2>$null
} else {
    Write-Host ""
    Write-Host "ℹ️  Beads chưa cài. Để cài:" -ForegroundColor Yellow
    Write-Host "   npm install -g @beads/bd && bd init && bd setup claude"
}

# ── Setup OpenSpec (nếu openspec đã cài) ─────────────────────────────────────
if (Get-Command openspec -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "📋 Phát hiện OpenSpec — chạy openspec init..."
    openspec init 2>$null
} else {
    Write-Host ""
    Write-Host "ℹ️  OpenSpec chưa cài. Để cài:" -ForegroundColor Yellow
    Write-Host "   npm install -g @fission-ai/openspec && openspec init"
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ agent-flow framework đã cài xong!" -ForegroundColor Green
Write-Host ""
Write-Host "Bước tiếp theo:"
Write-Host "  1. Điền CLAUDE.md (thay tất cả <placeholder>)"
Write-Host "  2. Đọc playbook: docs\playbook\README.md"
Write-Host "  3. Superpowers: /install superpowers (trong Claude Code chat)"
Write-Host ""
Write-Host "Tài liệu: https://github.com/hungngominh/agent-flow"
Write-Host ""
