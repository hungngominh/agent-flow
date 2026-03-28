# agent-flow

Bộ khung vận hành AI cho team nhỏ (2–5 người) — 1 lệnh cài xong.

## Cài vào dự án mới

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/hungngominh/agent-flow/main/scripts/install.ps1 | iex
```

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/hungngominh/agent-flow/main/scripts/install.sh | bash
```

Lệnh này tự động:
- Copy `CLAUDE.md` vào project (điền placeholder là xong)
- Tạo `docs/templates/` (Beads schema + handoff note)
- Tạo `docs/playbook/` (7 sections hướng dẫn)
- Tạo `scripts/validate-templates.sh`
- Chạy `bd init && bd setup claude` nếu Beads đã cài
- Chạy `openspec init` nếu OpenSpec đã cài

## 5 tầng framework

```
TẦNG 4 — Superpowers    → AI operating procedure
TẦNG 3 — Beads          → Task graph ("bd ready" = làm gì tiếp)
TẦNG 2 — OpenSpec       → Requirement contract (what & why)
TẦNG 1 — CLAUDE.md      → Luật bất biến cho AI
TẦNG 0 — Intake/Triage  → Phân loại trước khi làm gì
```

**Layer Precedence:** `CLAUDE.md > OpenSpec > Beads > Superpowers`

## 3 Flow levels

| Flow | Khi nào dùng |
|------|-------------|
| **LITE** | Rollback cost LOW + scope SMALL |
| **STANDARD** | 1 service, rollback cost LOW/MEDIUM |
| **FULL** | Multi-service, rollback cost HIGH, đổi auth/billing/data |

## Cài thủ công (từng bước)

```bash
# 1. CLAUDE.md
cp CLAUDE.md.template CLAUDE.md
# Điền tất cả <placeholder> trong CLAUDE.md

# 2. Beads
npm install -g @beads/bd
bd init && bd setup claude

# 3. OpenSpec
npm install -g @fission-ai/openspec
openspec init

# 4. Superpowers (trong Claude Code chat)
# /install superpowers
```

## Cấu trúc file

```
project/
├── CLAUDE.md                          ← fill & commit vào repo
├── docs/
│   ├── templates/
│   │   ├── beads-task.yaml            ← copy cho mỗi Beads task
│   │   └── handoff-note.md            ← viết khi kết thúc session
│   └── playbook/
│       ├── README.md                  ← entry point
│       ├── 01-architecture.md         ← 5-layer overview
│       ├── 02-triage.md               ← intake & triage guide
│       ├── 03-flows.md                ← LITE / STANDARD / FULL
│       ├── 04-beads-guide.md          ← Beads usage
│       ├── 05-openspec-guide.md       ← OpenSpec usage
│       ├── 06-quality-gates.md        ← quality gate checklist
│       └── 07-handoff-protocol.md     ← handoff ritual
└── scripts/
    └── validate-templates.sh          ← kiểm tra không còn placeholder
```

## Validate

```bash
bash scripts/validate-templates.sh
```

## Playbook

Xem `docs/playbook/README.md` để bắt đầu.
