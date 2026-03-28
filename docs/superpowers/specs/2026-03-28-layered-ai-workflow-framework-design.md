# Layered AI Workflow Framework — Design Doc

**Date:** 2026-03-28
**Status:** Approved
**Scope:** Team nhỏ (2–5 người), full-stack / automation / frontend / backend
**Tools:** CLAUDE.md · OpenSpec · Beads (`bd`) · Superpowers Skills

---

## 1. Mục tiêu

Xây dựng một **bộ khung vận hành AI hoàn chỉnh** cho team nhỏ gồm:
- **Template:** bộ file có thể dùng ngay (CLAUDE.md, Beads task schema, OpenSpec structure)
- **Playbook:** giải thích quy trình từ A–Z để team hiểu tại sao, không chỉ làm theo

Giải quyết 3 điểm đau đồng thời:
1. Thiếu nhất quán / visibility giữa các thành viên
2. AI mất context, làm sai spec, quên task đã thống nhất
3. Không biết cách giao việc hiệu quả cho AI

---

## 2. Kiến trúc: 5 Tầng (Tầng 0–4)

```
┌─────────────────────────────────────────────────────┐
│  TẦNG 4 — OPERATING PROCEDURE (Superpowers)         │
│  AI operating system: brainstorm → plan → TDD →     │
│  review → verify. KHÔNG chứa business workflow.     │
├─────────────────────────────────────────────────────┤
│  TẦNG 3 — EXECUTION LEDGER (Beads)                  │
│  Task graph: dependency, claim, status + link về    │
│  spec/design/decision/PR. "bd ready" = next action. │
├─────────────────────────────────────────────────────┤
│  TẦNG 2 — REQUIREMENT CONTRACT (OpenSpec)           │
│  Source of truth: what & why. propose → spec →      │
│  design → tasks → archive. Drift-free.              │
├─────────────────────────────────────────────────────┤
│  TẦNG 1 — BEHAVIORAL CONTRACT (CLAUDE.md)           │
│  Luật bất biến: code style, conventions, ngôn ngữ, │
│  tool allow/deny, test rules, refactor rules.       │
├─────────────────────────────────────────────────────┤
│  TẦNG 0 — INTAKE / TRIAGE                           │
│  Phân loại: loại việc? rollback cost? flow nào?     │
└─────────────────────────────────────────────────────┘
```

### Vai trò từng tầng (không overlap)

| Tầng | Tool | Trả lời câu hỏi |
|------|------|-----------------|
| 4 | Superpowers | AI phải thực hiện công việc theo quy trình nào? |
| 3 | Beads | Bây giờ phải làm việc gì tiếp theo? |
| 2 | OpenSpec | Ta đang xây cái gì và tại sao? |
| 1 | CLAUDE.md | AI được phép hành xử như thế nào? |
| 0 | Triage | Việc này thuộc loại gì, đi theo flow nào? |

---

## 3. Layer Precedence

```
CLAUDE.md  >  OpenSpec  >  Beads  >  Superpowers
```

**Quy tắc cưỡng chế:** Tầng thấp hơn KHÔNG được override tầng cao hơn. Khi xung đột, phải cập nhật hoặc vô hiệu hóa artifact ở tầng thấp hơn.

| Tình huống | Xử lý |
|------------|-------|
| Superpowers bảo "dùng TDD" ↔ CLAUDE.md bảo "không snapshot test" | Theo CLAUDE.md |
| Beads task: "làm API A" ↔ OpenSpec: "API A đã hủy" | Theo OpenSpec → update Beads |
| OpenSpec đổi requirement | → Beads tasks cũ phải update |
| CLAUDE.md đổi rule | → Workflow Superpowers cũ xem là invalid cho repo này |

---

## 4. Tầng 0: Intake / Triage

### Câu hỏi phân loại (AI PHẢI trả lời trước khi làm gì)

1. **Loại công việc?**
   `idea | bug | feature | refactor | spike | docs | chore`

2. **Rollback cost nếu làm sai?**
   - `LOW` — có thể revert nhanh, không ảnh hưởng data/contract
   - `HIGH` — chạm: auth / billing / data migration / permission / webhook contract / external API contract

3. **Scope?**
   - `SMALL` — 1 file hoặc vài file cùng module
   - `MEDIUM` — 1 service hoặc 1 bounded context
   - `LARGE` — multi-service, cross-team, hoặc cần migration/rollout plan

### 3 Flow Levels

> **Rule cưỡng chế:** Nếu rollback cost = HIGH → KHÔNG được dùng LITE, dù scope trông nhỏ.

| Level | Điều kiện | Flow |
|-------|-----------|------|
| **LITE** | Rollback cost LOW **và** scope SMALL. Bug nhỏ, chore, docs, config thường. | note ngắn → code → test → Beads update → done |
| **STANDARD** | 1 service hoặc 1 bounded context. Không đổi external contract lớn. Rollback cost LOW/MEDIUM. | OpenSpec propose → Beads → Superpowers execute → verify → archive |
| **FULL** | Multi-service; đổi data model quan trọng; đổi auth/billing/permission contract; cần migration hoặc rollout plan; rollback cost HIGH. | brainstorm → OpenSpec full flow → Beads graph → TDD → review → verify → archive |

---

## 5. Tầng 3: Beads Task Schema

```yaml
id: bd-xxxx
title: "Mô tả ngắn, rõ ràng"
type: bug | feature | task | epic | chore | message
priority: P0 | P1 | P2 | P3 | P4
status: todo | ready | in_progress | blocked | review | done

# SOURCE LINKS — task này sinh ra từ đâu?
source:
  spec_ref: openspec/specs/<domain>/spec.md#<requirement-anchor>
  design_ref: openspec/changes/<change-name>/design.md
  decision_ref: openspec/changes/<change-name>/design.md#<decision-anchor>
  discovered_from: null  # hoặc bd-xxxx nếu sinh ra khi làm task khác

# EXECUTION LINKS — đã thực thi bằng thay đổi kỹ thuật nào?
execution:
  branch_ref: null        # git branch name
  commit_ref: null        # git commit SHA hoặc short message
  pr_ref: null            # PR URL hoặc số
  verification_ref: null  # một trong các loại được chấp nhận:
                          #   - CI run link (GitHub Actions, GitLab CI, ...)
                          #   - test report (jest --coverage output, ...)
                          #   - screenshot/manual verification note
                          #   - benchmark result

# ACCEPTANCE CRITERIA
acceptance:
  delivery:   # behavior đúng, edge case cover đủ
    - [ ] <mô tả behavior cần đúng, trỏ về scenario trong spec nếu có>
  governance: # dấu vết vận hành
    - [ ] tests_added_or_updated: required when applicable
    - [ ] verification_passed: yes
    - [ ] spec_delta_checked: yes
    - [ ] implementation_links_present: yes

# DEPENDENCY
depends_on: []          # danh sách bd-id phải xong trước
blocked_by: []          # danh sách bd-id hoặc external blocker string
blocked_reason: []      # mô tả lý do, tương ứng 1-1 với blocked_by
```

---

## 6. Quality Gate trước `bd close`

AI phải xác nhận EXPLICIT từng mục — không được tự assume "xong rồi":

```
DELIVERY
  ✅ Đã verify behavior theo TỪNG delivery acceptance criteria
  ✅ Đã verify đúng spec requirement (không chỉ dựa vào test pass)
  ✅ Tests pass — hoặc ghi rõ "not applicable" + lý do

GOVERNANCE
  ✅ Spec delta: archived / confirmed "no update needed"
  ✅ execution.pr_ref đã được điền
  ✅ execution.verification_ref đã được điền
     (CI link / test report / screenshot / benchmark — chọn loại phù hợp)
```

---

## 7. Anti-drift — Cả 2 chiều

| Trigger | Hành động bắt buộc |
|---------|-------------------|
| Code thay đổi behavior | Mở delta spec trong OpenSpec |
| Task close | Confirm spec up-to-date hoặc ghi rõ "no update needed" |
| **Spec/design thay đổi requirement** | **Update Beads tasks / dependency / priority / status** |
| Session kết thúc | `bd dolt push` + viết handoff note |
| AI phát hiện việc ngoài scope | Tạo task mới với `discovered_from:<id>`, KHÔNG âm thầm làm |

**Rule discovered work:**
> AI không được tự ý làm bất kỳ việc nào ngoài scope task hiện tại. Phải tạo `bd create` với `discovered_from:<current-task-id>` và báo cho người dùng. "Tiện tay sửa luôn" là hành vi bị cấm.

---

## 8. Handoff Protocol — Nghi thức chính thức

Handoff note là bắt buộc khi kết thúc session. Format tối thiểu:

```markdown
## Handoff Note — [YYYY-MM-DD] [session-id]

### Đã làm
- [bd-xxxx] <tên task> — DONE, PR #<n>

### Dang dở
- [bd-xxxx] <tên task> — IN PROGRESS
  Lý do chưa xong: <mô tả>

### Blockers
- [bd-xxxx] blocked: <lý do cụ thể>

### Nên làm tiếp
- `bd ready` sẽ trả về [bd-xxxx] (<tên task tiếp theo>)

### Spec/task đã update
- <path spec> → delta merged / confirmed no update
- Beads sync: `bd dolt push` ✅

### Risks / Assumptions
- Giả định đang dùng: <ví dụ: Redis WATCH behavior cho concurrent refresh>
- Rủi ro còn tồn tại: <ví dụ: edge case X chưa được test trên prod load>
- Điều chưa verify được: <ví dụ: performance ở 10k concurrent users>
```

---

## 9. CLAUDE.md — Cấu trúc template

```markdown
# CLAUDE.md — [Project Name]

## 1. Immutable Rules
(không bao giờ thay đổi dù context nào)
- Ngôn ngữ code: <TypeScript / Go / Python / ...>
- Framework & conventions: <tên + link style guide>
- Ngôn ngữ phản hồi với user: <Tiếng Việt / English / ...>
- Tool được phép dùng: <danh sách>
- Tool không được phép dùng: <danh sách>

## 2. Execution Policy
(cách AI đưa ra quyết định)
- Tầng 0 Triage: AI PHẢI phân loại (loại việc / rollback cost / scope)
  trước khi làm bất cứ thứ gì.
- Layer precedence: CLAUDE.md > OpenSpec > Beads > Superpowers.
  Tầng thấp không override tầng cao; khi xung đột phải update artifact
  tầng thấp.
- Discovered work: tạo `bd create --deps discovered-from:<id>`,
  KHÔNG tự làm ngoài scope.

## 3. Quality Gates
(điều kiện bắt buộc trước khi claim done)
- Delivery acceptance: verify behavior, tests pass (or justified skip)
- Governance acceptance: spec_delta_checked, links present
- `bd close` prerequisites: xem Section 6 của design doc

## 4. Update Obligations
(khi nào AI BẮT BUỘC cập nhật artifact)
- Code đổi behavior → mở delta spec trong OpenSpec
- Spec/design đổi → sync lại Beads tasks
- Session kết thúc → handoff note + `bd dolt push`

## 5. Forbidden Behaviors
(AI tuyệt đối không được làm)
- Làm việc ngoài scope mà không tạo task
- Tự `bd close` khi chưa qua quality gate
- Override tầng cao bằng quyết định ở tầng thấp
- Báo "done" mà không verify against acceptance criteria
- Assume "test pass = spec correct"

## 6. Repo-Specific Commands
(lệnh chuẩn cho repo này — AI dùng chính xác các lệnh này)
- Test:         <lệnh>
- Lint/format:  <lệnh>
- Build:        <lệnh>
- Run local:    <lệnh>
- Definition of Done cho repo này:
  - [ ] Tests pass
  - [ ] Lint clean
  - [ ] <thêm tiêu chí repo-specific>
```

---

## 10. Luồng dữ liệu điển hình

### Feature mới (FULL flow)

```
Dev có idea
    │
    ▼
[Tầng 0] Triage → loại: feature / rollback cost / scope → Level
    │
    ▼
[Tầng 1 CLAUDE.md] AI đọc behavioral contract
    │
    ▼
[Tầng 4 Superpowers: brainstorming] Explore → clarify → design → approve
    │
    ▼
[Tầng 2 OpenSpec: /opsx:propose] proposal → specs → design → tasks.md
    │
    ▼
[Tầng 3 Beads] Import tasks từ tasks.md, link source refs, set dependencies
    │
    ▼
[Tầng 4 Superpowers: writing-plans → executing-plans]
    │
    ▼
[Tầng 3 Beads] bd ready → bd update --claim → làm việc
    │
    ▼
[Tầng 4 Superpowers: verification-before-completion + code-reviewer]
    │
    ▼
[Quality Gate] Delivery ✅ + Governance ✅ → bd close
    │
    ▼
[Tầng 2 OpenSpec: /opsx:archive] Merge delta → source of truth
    │
    ▼
[Handoff Protocol] bd dolt push + handoff note
```

### Bug nhỏ (LITE flow)

```
Bug report
    │
    ▼
[Tầng 0] Triage → rollback cost: LOW, scope: SMALL → Level: LITE
    │
    ▼
[Tầng 1 CLAUDE.md] Check relevant rules
    │
    ▼
[Tầng 3 Beads] bd create type:bug → bd update --claim
    │
    ▼
Fix + test
    │
    ▼
[Quality Gate] verify acceptance → bd close (governance minimal)
    │
    ▼
[Tầng 3 Beads] bd dolt push
```

---

## 11. Rủi ro vận hành và giảm thiểu

| Rủi ro | Biện pháp |
|--------|-----------|
| Over-process cho việc nhỏ | 3 flow levels + rollback cost rule |
| AI update không đồng bộ | Quality gate cưỡng chế trước bd close |
| Task graph thành requirement store | Beads chỉ giữ execution ledger; requirement ở OpenSpec |
| Drift code ↔ spec | Anti-drift 2 chiều |
| Context mất giữa session | Handoff protocol chính thức |
| Discovered work không track | Rule tạo task bắt buộc |
| AI chọn flow level sai | Rollback cost rule cưỡng chế |
