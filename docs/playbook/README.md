# AI Workflow Framework — Playbook

Bộ khung vận hành AI cho team nhỏ (2–5 người). Framework trả lời 5 câu hỏi:

| Câu hỏi | Tool |
|---------|------|
| Việc này là gì và đi flow nào? | Tầng 0 — Intake/Triage |
| AI được phép hành xử như thế nào? | Tầng 1 — CLAUDE.md |
| Ta đang xây cái gì và tại sao? | Tầng 2 — OpenSpec |
| Bây giờ phải làm gì tiếp theo? | Tầng 3 — Beads |
| AI thực hiện công việc theo quy trình nào? | Tầng 4 — Superpowers |

## Quick-start (dự án mới)

```bash
# 1. Copy template vào repo
cp /path/to/framework/CLAUDE.md.template ./CLAUDE.md
# 2. Mở CLAUDE.md, điền tất cả <placeholder>
# 3. Cài Beads
npm install -g @beads/bd && bd init
# 4. Cài OpenSpec
npm install -g @fission-ai/openspec && openspec init
# 5. Cài Superpowers (qua Claude Code plugin)
#    /install superpowers  (trong Claude Code chat)
```

## Các file trong framework này

| File | Mục đích |
|------|----------|
| `CLAUDE.md.template` | Copy vào repo, rename, fill placeholders |
| `docs/templates/beads-task.yaml` | Schema cho mỗi Beads task |
| `docs/templates/handoff-note.md` | Template viết handoff khi kết thúc session |
| `scripts/validate-templates.sh` | Kiểm tra templates còn placeholder chưa |

## Đọc thêm

1. [Kiến trúc tổng thể](01-architecture.md)
2. [Intake & Triage](02-triage.md)
3. [3 Flows: LITE / STANDARD / FULL](03-flows.md)
4. [Hướng dẫn Beads](04-beads-guide.md)
5. [Hướng dẫn OpenSpec](05-openspec-guide.md)
6. [Quality Gates & Anti-drift](06-quality-gates.md)
7. [Handoff Protocol](07-handoff-protocol.md)
