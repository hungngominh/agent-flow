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

### Re-triage — Dynamic Flow Adjustment

Triage không chỉ chạy 1 lần đầu. AI PHẢI re-triage khi phát hiện thông tin mới:

| Trigger | Hành động |
|---------|-----------|
| Discovered work làm tăng scope | Re-classify flow level |
| Phát hiện task chạm auth/billing/data/contract | Escalate lên STANDARD hoặc FULL ngay |
| Dependency mới xuất hiện làm tăng scope | Re-classify |
| Scope thu hẹp hơn dự kiến | Có thể downgrade flow |

**Rule:** Nếu flow level tăng → escalate ngay, không tiếp tục flow cũ. Nếu giảm → xác nhận với user trước khi downgrade.

---

## 5. Tầng 3: Beads Task Schema

```yaml
id: bd-xxxx
title: "Mô tả ngắn, rõ ràng"
type: bug | feature | task | epic | chore | message
priority: P0 | P1 | P2 | P3 | P4
status: todo | ready | in_progress | blocked | review | done

# INTENT — mục tiêu ban đầu của task (bất biến, không đổi theo spec evolution)
intent: "Implement JWT refresh token flow theo spec auth v1"

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
    - [ ] verify_against_spec: <scenario trong spec cần đúng>
    - [ ] verify_against_acceptance: <edge case / behavior cụ thể>
  governance: # dấu vết vận hành
    - [ ] tests_added_or_updated: required when applicable
    - [ ] verification_passed: yes
    - [ ] spec_delta_checked: yes
    - [ ] implementation_links_present: yes

# DEFINITION OF READY — task chỉ được set "ready" khi đủ các điều sau
ready_when:
  - spec_ref hoặc rationale rõ ràng
  - acceptance criteria có thể verify được
  - dependency đã rõ (không còn unknown blocker)
  - không còn ambiguity về scope

# DEPENDENCY
depends_on: []          # danh sách bd-id phải xong trước
blocked_by: []          # danh sách bd-id hoặc external blocker string
blocked_reason: []      # mô tả lý do, tương ứng 1-1 với blocked_by
```

**Lưu ý về `intent`:** Khi spec thay đổi, AI dùng `intent` để quyết định task còn valid không. Nếu intent bị invalidate → split hoặc recreate task, không cập nhật intent.

---

## 6. Quality Gate trước `bd close`

AI phải xác nhận EXPLICIT từng mục — không được tự assume "xong rồi":

```
DELIVERY
  ✅ verify_against_spec: đúng theo spec requirement (không chỉ test pass)
  ✅ verify_against_acceptance: đúng theo từng delivery acceptance criteria
  ✅ Tests pass — hoặc ghi rõ "not applicable" + lý do

GOVERNANCE
  ✅ Spec delta: archived / confirmed "no update needed"
  ✅ execution.pr_ref đã được điền
  ✅ execution.verification_ref đã được điền
     (CI link / test report / screenshot / benchmark — chọn loại phù hợp)

NEGATIVE CHECKS
  ❗ Không vi phạm bất kỳ rule nào trong CLAUDE.md
  ❗ Không introduce breaking change ngoài scope spec
  ❗ Không có behavior ngoài task scope trong code
```

---

## 7. Anti-drift — Cả 2 chiều + Task ↔ Code

| Trigger | Hành động bắt buộc |
|---------|-------------------|
| Code thay đổi behavior | Mở delta spec trong OpenSpec |
| Task close | Confirm spec up-to-date hoặc ghi rõ "no update needed" |
| **Spec/design thay đổi requirement** | **Update Beads tasks / dependency / priority / status** |
| **Code chứa behavior ngoài task scope** | **Tạo task mới (discovered_from) hoặc rollback phần dư** |
| Session kết thúc | `bd dolt push` + viết handoff note |
| AI phát hiện việc ngoài scope | Tạo task mới với `discovered_from:<id>`, KHÔNG âm thầm làm |

**Rule discovered work:**
> AI không được tự ý làm bất kỳ việc nào ngoài scope task hiện tại. Phải tạo `bd create` với `discovered_from:<current-task-id>` và báo cho người dùng. "Tiện tay sửa luôn" là hành vi bị cấm.

---

## 8. Handoff Protocol — Nghi thức chính thức

Handoff note là bắt buộc khi kết thúc session. Format tối thiểu:

```markdown
## Handoff Note — [YYYY-MM-DD] [session-id]

### State Snapshot
- Active branch: <branch-name>
- Current task: <bd-id> (status)
- Last successful verification: <CI run # hoặc test report link>

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
  trước khi làm bất cứ thứ gì. Re-triage khi phát hiện thông tin mới.
- Layer precedence: CLAUDE.md > OpenSpec > Beads > Superpowers.
  Tầng thấp không override tầng cao; khi xung đột phải update artifact
  tầng thấp.
- Discovered work: tạo `bd create --deps discovered-from:<id>`,
  KHÔNG tự làm ngoài scope.
- Decision boundary: AI PHẢI hỏi lại user (không tự quyết) khi:
  - Spec không rõ hoặc mâu thuẫn
  - Có nhiều giải pháp đều hợp lý nhưng trade-off lớn
  - Thay đổi có thể ảnh hưởng external contract

## 3. Quality Gates
(điều kiện bắt buộc trước khi claim done)
- verify_against_spec: behavior đúng theo spec requirement
- verify_against_acceptance: đúng theo từng acceptance criteria
- Negative checks: không vi phạm CLAUDE.md rules, không breaking change ngoài scope
- Governance: spec_delta_checked, implementation_links_present
- `bd close` prerequisites (inline):
  DELIVERY:   ✅ verify_against_spec, ✅ verify_against_acceptance, ✅ tests pass or N/A
  GOVERNANCE: ✅ spec delta archived/confirmed, ✅ pr_ref filled, ✅ verification_ref filled
  NEGATIVE:   ❗ no CLAUDE.md violations, ❗ no out-of-scope breaking changes

## 4. Update Obligations
(khi nào AI BẮT BUỘC cập nhật artifact)
- Code đổi behavior → mở delta spec trong OpenSpec
- Spec/design đổi → sync lại Beads tasks
- Code chứa behavior ngoài scope → tạo discovered task hoặc rollback
- Session kết thúc → handoff note + `bd dolt push`

## 5. Forbidden Behaviors
(AI tuyệt đối không được làm)
- Làm việc ngoài scope mà không tạo task
- Tự `bd close` khi chưa qua quality gate
- Override tầng cao bằng quyết định ở tầng thấp
- Báo "done" mà không verify_against_spec và verify_against_acceptance
- Assume "test pass = spec correct"
- Tự quyết khi có trade-off lớn hoặc spec ambiguous

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

Tất cả flow đều có **abort path**: nếu verification FAIL, không được `bd close`. Phải:
1. Update design trong OpenSpec, hoặc
2. Tạo task fix mới (discovered_from), hoặc
3. Re-triage nếu scope thực sự đã thay đổi.

### Feature trung bình (STANDARD flow)

```
Dev có idea / bug rollback cost MEDIUM
    │
    ▼
[Tầng 0] Triage → 1 service / 1 bounded context → Level: STANDARD
    │
    ▼
[Tầng 1 CLAUDE.md] AI đọc behavioral contract
    │
    ▼
[Tầng 2 OpenSpec: /opsx:propose] proposal → specs → design → tasks.md
    │  (Bỏ qua brainstorming — scope đã rõ)
    ▼
[Tầng 3 Beads] Import tasks, link source refs, set dependencies
    │
    ▼
[Tầng 4 Superpowers: executing-plans]
    │
    ▼
[Tầng 3 Beads] bd ready → bd update --claim → làm việc
    │
    ▼
[Tầng 4 Superpowers: verification-before-completion]
    │
    ├── PASS ──▶ [Quality Gate] Delivery ✅ + Governance ✅ → bd close
    │                │
    │                ▼
    │           [Tầng 2 OpenSpec: /opsx:archive] → bd dolt push
    │
    └── FAIL ──▶ [Abort path]
                  ├── Update design (OpenSpec) → re-execute
                  ├── Tạo task fix (discovered_from) → vào queue
                  └── Re-triage nếu scope đổi → escalate flow nếu cần
```

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
    ├── PASS ──▶ [Quality Gate] Delivery ✅ + Governance ✅ → bd close
    │                │
    │                ▼
    │           [Tầng 2 OpenSpec: /opsx:archive] Merge delta → source of truth
    │                │
    │                ▼
    │           [Handoff Protocol] bd dolt push + handoff note
    │
    └── FAIL ──▶ [Abort path]
                  ├── Update design (OpenSpec) → re-execute
                  ├── Tạo task fix (discovered_from) → vào queue
                  └── Re-triage nếu scope đổi → escalate flow nếu cần
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
    ├── PASS ──▶ [Quality Gate] verify_against_spec + governance minimal
    │                │
    │                ▼
    │           bd close → bd dolt push
    │
    └── FAIL ──▶ Tạo task fix → re-triage nếu rollback cost hóa ra HIGH
```

---

## 11. Rủi ro vận hành và giảm thiểu

| Rủi ro | Biện pháp |
|--------|-----------|
| Over-process cho việc nhỏ | 3 flow levels + rollback cost rule |
| AI update không đồng bộ | Quality gate cưỡng chế trước bd close |
| Task graph thành requirement store | Beads chỉ giữ execution ledger; requirement ở OpenSpec |
| Drift code ↔ spec | Anti-drift 2 chiều |
| Drift task ↔ code (AI làm thêm ngoài scope) | Anti-drift row "code chứa behavior ngoài task scope" |
| Context mất giữa session | Handoff protocol + state snapshot |
| Discovered work không track | Rule tạo task bắt buộc |
| AI chọn flow level sai | Rollback cost rule + re-triage trigger |
| AI tự quyết khi ambiguous | Decision boundary rule trong CLAUDE.md |
| Task "ready" nhưng chưa làm được | Definition of Ready trong task schema |
| Spec evolve làm task invalid | Intent lock → split/recreate task |
| Verification pass nhưng lệch requirement | verify_against_spec tách biệt với test pass |
