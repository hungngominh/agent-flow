# Hướng dẫn Beads

## Beads là gì trong framework này?

Beads giữ **execution state** — không phải requirement, không phải spec.

Beads trả lời: "Bây giờ làm gì? Task nào đang blocked? Task nào sẵn sàng?"

OpenSpec trả lời: "Đang xây cái gì và tại sao?"

**Đừng nhầm lẫn:** Nếu bạn thấy mình đang viết requirement vào Beads task description → đó là OpenSpec, không phải Beads.

## Setup

```bash
npm install -g @beads/bd
cd your-project
bd init
bd setup claude    # cài SessionStart + PreCompact hooks cho Claude Code
```

## Workflow AI với Beads

```bash
# Bắt đầu session: xem task nào ready
bd ready

# Claim task để làm (atomic — tránh 2 agents lấy cùng task)
bd update bd-a1b2 --claim

# Phát hiện work mới trong khi làm
bd create "Fix edge case in refresh" --type bug --deps discovered-from:bd-a1b2

# Kết thúc task
bd close bd-a1b2 --reason "JWT refresh implemented, PR #42"

# Sync cuối session
bd dolt push
```

## Điền task schema đúng cách

Xem template tại `docs/templates/beads-task.yaml`.

### Intent — viết một lần, không đổi

```yaml
intent: "Add rate limiting to /auth/login endpoint (spec: auth/spec.md#req-rate-limit)"
```

Khi spec thay đổi → dùng intent để hỏi: task này còn valid không?
- Còn valid → cập nhật `source.spec_ref`, giữ nguyên intent
- Không còn valid → `bd close` với reason "superseded", tạo task mới

### Source links — trỏ về nguồn gốc

```yaml
source:
  spec_ref: "openspec/specs/auth/spec.md#requirement-rate-limiting"
  design_ref: "openspec/changes/auth-rate-limit/design.md"
  decision_ref: "openspec/changes/auth-rate-limit/design.md#decision-redis-vs-memory"
```

Nếu là LITE task không có OpenSpec change:
```yaml
source:
  spec_ref: null
  design_ref: null
  decision_ref: null
  discovered_from: null  # hoặc bd-xxxx nếu spawned từ task khác
```

### Execution links — điền khi làm xong

```yaml
execution:
  branch_ref: "feature/auth-rate-limit"
  commit_ref: "abc1234"
  pr_ref: "https://github.com/org/repo/pull/42"
  verification_ref: "https://github.com/org/repo/actions/runs/123456"
```

`verification_ref` bắt buộc trước `bd close`. Loại được chấp nhận:
- CI run link
- Test report output
- Screenshot/manual note (dạng: `manual: verified login blocked after 5 failed attempts`)
- Benchmark result

### Definition of Ready — task chỉ ready khi đủ điều kiện

Trước khi đổi status → `ready`, tự check:
- `spec_ref` hoặc rationale rõ ràng
- Acceptance criteria có thể verify (không mơ hồ)
- Dependency đã biết hết
- Scope không còn ambiguous

## Status lifecycle

```
todo → ready → in_progress → review → done
                   ↓
                blocked → (unblocked) → in_progress
```

Task không được nhảy từ `in_progress` thẳng sang `done` mà bỏ qua quality gate.
