# install.ps1 - Bootstrap agent-flow framework in current project (Windows)
# Usage: irm https://raw.githubusercontent.com/hungngominh/agent-flow/master/scripts/install.ps1 | iex

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$REPO = "https://raw.githubusercontent.com/hungngominh/agent-flow/master"

function Download-File($url, $dest) {
    $dir = Split-Path $dest -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

Write-Host ""
Write-Host "agent-flow - Cai dat AI Workflow Framework" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Tao thu muc
New-Item -ItemType Directory -Path "docs\templates" -Force | Out-Null
New-Item -ItemType Directory -Path "docs\playbook"  -Force | Out-Null
New-Item -ItemType Directory -Path "scripts"         -Force | Out-Null

# Download templates
Write-Host "Tai templates..."
Download-File "$REPO/CLAUDE.md.template"             "CLAUDE.md.template"
Download-File "$REPO/docs/templates/beads-task.yaml" "docs\templates\beads-task.yaml"
Download-File "$REPO/docs/templates/handoff-note.md" "docs\templates\handoff-note.md"

# Download playbook
Write-Host "Tai playbook..."
$playbooks = @(
    "README.md", "01-architecture.md", "02-triage.md", "03-flows.md",
    "04-beads-guide.md", "05-openspec-guide.md", "06-quality-gates.md",
    "07-handoff-protocol.md"
)
foreach ($f in $playbooks) {
    Download-File "$REPO/docs/playbook/$f" "docs\playbook\$f"
}

# Download validation script
Write-Host "Tai validation script..."
Download-File "$REPO/scripts/validate-templates.sh" "scripts\validate-templates.sh"

# Copy CLAUDE.md
if (-not (Test-Path "CLAUDE.md")) {
    Copy-Item "CLAUDE.md.template" "CLAUDE.md"
    Write-Host ""
    Write-Host "[!] CLAUDE.md da duoc tao - can dien thong tin du an:" -ForegroundColor Yellow
    Write-Host "    Mo CLAUDE.md va thay tat ca <placeholder>" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "[i] CLAUDE.md da ton tai - giu nguyen, khong ghi de." -ForegroundColor Yellow
}

# Setup Beads (neu bd da cai)
if (Get-Command bd -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "Phat hien Beads - chay bd init + bd setup claude..."
    bd init 2>$null; bd setup claude 2>$null
} else {
    Write-Host ""
    Write-Host "[i] Beads chua cai. De cai:" -ForegroundColor Yellow
    Write-Host "    npm install -g @beads/bd && bd init && bd setup claude"
}

# Setup OpenSpec (neu openspec da cai)
if (Get-Command openspec -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "Phat hien OpenSpec - chay openspec init..."
    openspec init 2>$null
} else {
    Write-Host ""
    Write-Host "[i] OpenSpec chua cai. De cai:" -ForegroundColor Yellow
    Write-Host "    npm install -g @fission-ai/openspec && openspec init"
}

# Done
Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "OK: agent-flow framework da cai xong!" -ForegroundColor Green
Write-Host ""
Write-Host "Buoc tiep theo:"
Write-Host "  1. Dien CLAUDE.md (thay tat ca <placeholder>)"
Write-Host "  2. Doc playbook: docs\playbook\README.md"
Write-Host "  3. Superpowers: /install superpowers (trong Claude Code chat)"
Write-Host ""
Write-Host "Tai lieu: https://github.com/hungngominh/agent-flow"
Write-Host ""
