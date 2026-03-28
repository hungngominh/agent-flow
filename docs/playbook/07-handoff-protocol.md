# Handoff Protocol

## Tại sao handoff quan trọng?

AI session mới bắt đầu không có memory của session cũ. Không có handoff note, AI phải đoán:
- Task nào đang làm dở?
- Blocker là gì?
- Spec nào đã cập nhật, cái nào chưa?
- Assumption đang dùng là gì?

Kết quả: AI re-do work, inconsistent với session trước, bỏ sót blocker.

## Khi nào viết handoff note?

Bắt buộc khi:
- Kết thúc session (dù đã xong hay chưa)
- Chuyển task cho người khác / AI agent khác
- Session bị gián đoạn không lường trước

## Cách viết handoff note

Copy từ `docs/templates/handoff-note.md`. Điền đầy đủ.

Không được bỏ trống **Risks/Assumptions** nếu còn bất kỳ uncertainty nào.

## Session start ritual

Khi bắt đầu session mới, AI làm theo thứ tự:

```bash
# 1. Xem handoff note gần nhất (nếu có)
ls -lt handoffs/ | head -3   # hoặc nơi bạn lưu

# 2. Sync Beads
bd dolt pull

# 3. Xem task graph
bd ready           # task nào sẵn sàng
bd list --status in_progress   # task nào đang dang dở

# 4. Đọc CLAUDE.md (nếu chưa đọc trong session này)
```

## Session end ritual

```bash
# 1. Chạy quality gate trước mọi bd close
# (xem docs/playbook/06-quality-gates.md)

# 2. Update task status
bd update bd-xxxx --status review  # hoặc done nếu qua gate

# 3. Viết handoff note
# copy docs/templates/handoff-note.md → handoffs/YYYY-MM-DD-<session>.md

# 4. Sync
bd dolt push

# 5. Commit handoff note
git add handoffs/
git commit -m "chore: handoff note YYYY-MM-DD"
```

## State snapshot — bắt buộc trong handoff

```markdown
## State Snapshot
- Active branch: feature/auth-rate-limit
- Current task: bd-a1b2 — in_progress
- Last successful verification: https://github.com/org/repo/actions/runs/123456
```

Nếu thiếu state snapshot, người tiếp theo sẽ mất 10–15 phút chỉ để tìm lại context.

## Handoff giữa nhiều AI agents

Khi dùng multiple AI agents (parallel workflows):

```bash
# Agent A kết thúc:
bd close bd-a1b2 --reason "Done"
bd dolt push          # BẮTBUỘC trước khi agent B bắt đầu

# Agent B bắt đầu:
bd dolt pull          # BẮTBUỘC trước khi claim task
bd ready
bd update bd-c3d4 --claim
```

Nếu bỏ qua `bd dolt push/pull`, hai agents có thể claim cùng task.
