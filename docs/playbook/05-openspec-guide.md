# Hướng dẫn OpenSpec

## OpenSpec là gì trong framework này?

OpenSpec giữ **requirement contract** — nguồn sự thật về "ta đang xây cái gì và tại sao".

OpenSpec KHÔNG giữ: task status, ai đang làm gì, PR ở đâu — đó là Beads.

## Setup

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init   # chọn "claude" làm tool
```

## Folder structure sau init

```
your-project/
└── openspec/
    ├── specs/           ← source of truth: hệ thống HIỆN TẠI behave như thế nào
    │   └── <domain>/
    │       └── spec.md
    └── changes/         ← đang thay đổi: một folder per feature/fix
        └── <change-name>/
            ├── proposal.md
            ├── specs/        ← delta spec (ADDED/MODIFIED/REMOVED)
            ├── design.md
            └── tasks.md
```

## Workflow: propose → implement → archive

### 1. Propose (tạo artifact)

```
# STANDARD / FULL flow:
/opsx:propose <change-name>
# → tạo proposal.md, delta specs, design.md, tasks.md trong một lần

# Hoặc từng bước (expanded):
/opsx:new <change-name>    # tạo folder
/opsx:ff                   # fast-forward: tạo tất cả artifact
```

### 2. Implement

- Import tasks từ `tasks.md` vào Beads
- Làm việc theo Beads task graph
- Mỗi task phải verify_against_spec trước khi close

### 3. Archive (sau khi tất cả tasks done)

```
/opsx:archive
# → merge delta spec vào openspec/specs/
# → move change folder vào openspec/changes/archive/YYYY-MM-DD-<name>/
```

Sau archive: `openspec/specs/` phản ánh behavior mới của hệ thống.

## Delta spec format

Delta spec mô tả **thay đổi** — không viết lại toàn bộ spec.

```markdown
# Delta: Auth

## ADDED Requirements
### Requirement: Rate Limiting
The system SHALL block login after 5 failed attempts within 15 minutes.
#### Scenario: Too many failures
- GIVEN 5 failed login attempts within 15 minutes
- WHEN user attempts 6th login
- THEN request is blocked with HTTP 429
- AND retry-after header is set

## MODIFIED Requirements
### Requirement: Session Expiration
The system MUST expire sessions after 15 minutes of inactivity.
(Previously: 30 minutes)

## REMOVED Requirements
### Requirement: Remember Me checkbox
(Deprecated — use 2FA instead)
```

## Anti-drift với OpenSpec

**Chiều 1 — code đổi → spec update:**
Khi code thay đổi behavior, mở `/opsx:new <name>` và viết delta spec.
Không được merge code mà không có spec delta (hoặc explicit confirm "no spec update needed").

**Chiều 2 — spec đổi → Beads update:**
Khi chỉnh sửa `design.md` hoặc delta spec:
- Kiểm tra Beads tasks có bị ảnh hưởng không
- Update priority / dependency / status của tasks liên quan
