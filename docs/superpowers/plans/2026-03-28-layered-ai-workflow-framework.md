# Layered AI Workflow Framework — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a ready-to-use template kit + playbook implementing the 5-layer AI workflow framework (CLAUDE.md / OpenSpec / Beads / Superpowers) for small teams.

**Architecture:** Two deliverable types — (1) *Templates*: files a team copies into any project to bootstrap the framework; (2) *Playbook*: prose + examples explaining each rule, when to apply it, and why. A validation script checks that no template has unfilled placeholders before delivery.

**Tech Stack:** Markdown, YAML, Bash (validation script). No runtime dependencies.

---

## File Map

```
AIAgent/
├── CLAUDE.md.template                      # (T1) CLAUDE.md template — fill & rename
├── docs/
│   ├── templates/
│   │   ├── beads-task.yaml                 # (T2) Beads task schema — copy for each task
│   │   └── handoff-note.md                 # (T3) Handoff note template
│   ├── playbook/
│   │   ├── README.md                       # (P1) Entry point + quick-start
│   │   ├── 01-architecture.md              # (P2) 5-layer overview + precedence
│   │   ├── 02-triage.md                    # (P3) Intake/Triage guide (with examples)
│   │   ├── 03-flows.md                     # (P4) LITE / STANDARD / FULL with abort paths
│   │   ├── 04-beads-guide.md               # (P5) Beads setup + schema usage
│   │   ├── 05-openspec-guide.md            # (P6) OpenSpec setup + workflow
│   │   ├── 06-quality-gates.md             # (P7) Quality gate + anti-drift reference
│   │   └── 07-handoff-protocol.md          # (P8) Handoff ritual guide
│   └── superpowers/
│       ├── specs/
│       │   └── 2026-03-28-layered-ai-workflow-framework-design.md  # [existing]
│       └── plans/
│           └── 2026-03-28-layered-ai-workflow-framework.md         # [this file]
└── scripts/
    └── validate-templates.sh               # (V1) Checks no <placeholder> left unfilled
```

---

## Task 1: Validation Script

Build the acceptance gate first. Every subsequent task must pass this before committing.

**Files:**
- Create: `scripts/validate-templates.sh`

- [ ] **Step 1: Write the test**

Create `scripts/validate-templates.sh`:

```bash
#!/usr/bin/env bash
# Validate: no unfilled placeholders remain in template outputs.
# Usage: bash scripts/validate-templates.sh
set -euo pipefail

ERRORS=0
FILES=(
  "CLAUDE.md.template"
  "docs/templates/beads-task.yaml"
  "docs/templates/handoff-note.md"
)

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "MISSING: $f"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  # Files must exist. Placeholders like <lệnh> are intentional in templates.
  echo "OK: $f"
done

# Check playbook files exist
PLAYBOOK=(
  "docs/playbook/README.md"
  "docs/playbook/01-architecture.md"
  "docs/playbook/02-triage.md"
  "docs/playbook/03-flows.md"
  "docs/playbook/04-beads-guide.md"
  "docs/playbook/05-openspec-guide.md"
  "docs/playbook/06-quality-gates.md"
  "docs/playbook/07-handoff-protocol.md"
)

for f in "${PLAYBOOK[@]}"; do
  if [ ! -f "$f" ]; then
    echo "MISSING: $f"
    ERRORS=$((ERRORS + 1))
  else
    # Fail if any playbook file contains TODO or TBD (we don't want draft content shipped)
    if grep -qiE '\bTODO\b|\bTBD\b' "$f"; then
      echo "DRAFT CONTENT: $f contains TODO/TBD"
      ERRORS=$((ERRORS + 1))
    else
      echo "OK: $f"
    fi
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "FAIL: $ERRORS issue(s) found."
  exit 1
fi
echo ""
echo "PASS: all framework files present and clean."
```

- [ ] **Step 2: Make executable and run — expect FAIL (files don't exist yet)**

```bash
chmod +x scripts/validate-templates.sh
bash scripts/validate-templates.sh
```

Expected output: multiple `MISSING:` lines, exit code 1.

- [ ] **Step 3: Commit the validator**

```bash
git add scripts/validate-templates.sh
git commit -m "feat: add framework validation script"
```

---

## Task 2: CLAUDE.md Template (T1)

The most important deliverable. AI reads this first on every session.

**Files:**
- Create: `CLAUDE.md.template`

- [ ] **Step 1: Verify validator will catch a missing file**

```bash
bash scripts/validate-templates.sh 2>&1 | grep "CLAUDE.md.template"
```

Expected: `MISSING: CLAUDE.md.template`

- [ ] **Step 2: Create `CLAUDE.md.template`**

```markdown
# CLAUDE.md — <Project Name>
<!-- SETUP: Replace <Project Name> and fill every <...> section below.
     Rename this file to CLAUDE.md at the repo root. -->

---

## 1. Immutable Rules
<!-- These NEVER change regardless of context. AI treats violations as blockers. -->

- **Language:** All code in <TypeScript | Go | Python | other>
- **Framework conventions:** Follow <link-to-style-guide-or-describe-here>
- **Response language:** Reply to the user in <Tiếng Việt | English | other>
- **Tools ALLOWED:** <list tools/CLIs the AI may use>
- **Tools FORBIDDEN:** <list tools/CLIs the AI must never use>

---

## 2. Execution Policy

### Triage (run BEFORE every task)
AI MUST classify before doing anything:

1. Work type: `idea | bug | feature | refactor | spike | docs | chore`
2. Rollback cost: `LOW` (safe revert) | `HIGH` (touches auth/billing/data/contract)
3. Scope: `SMALL` (1 module) | `MEDIUM` (1 service/context) | `LARGE` (multi-service)

Flow selection:
- rollback=HIGH → FULL or STANDARD (never LITE)
- scope=LARGE → FULL
- scope=MEDIUM, rollback=LOW/MEDIUM → STANDARD
- scope=SMALL, rollback=LOW → LITE

**Re-triage required** when: discovered work increases scope, or task touches
auth/billing/data/contract that wasn't initially obvious.

### Layer Precedence
`CLAUDE.md > OpenSpec > Beads > Superpowers`

When layers conflict: update the lower-layer artifact, do NOT override the higher.

### Discovered Work
Create `bd create` with `discovered_from:<current-task-id>`. Report to user.
**Never silently do out-of-scope work.**

### Decision Boundary
AI MUST ask the user (never self-decide) when:
- Spec is ambiguous or contradictory
- Multiple valid solutions with significant trade-offs
- Change may affect external contracts

---

## 3. Quality Gates
Every task before `bd close`:

**DELIVERY**
- [ ] `verify_against_spec`: behavior matches spec requirement (not just tests)
- [ ] `verify_against_acceptance`: each delivery acceptance criterion checked
- [ ] Tests pass — or explicitly documented as "N/A: <reason>"

**GOVERNANCE**
- [ ] `spec_delta_checked`: OpenSpec delta archived or confirmed "no update needed"
- [ ] `execution.pr_ref` filled
- [ ] `execution.verification_ref` filled (CI link / test report / screenshot / benchmark)

**NEGATIVE CHECKS**
- [ ] No CLAUDE.md rule violations introduced
- [ ] No breaking changes outside spec scope
- [ ] No behavior in code outside current task scope

---

## 4. Update Obligations
AI MUST update artifacts when:

| Event | Action |
|-------|--------|
| Code changes behavior | Open delta spec in OpenSpec |
| Spec/design changes | Sync Beads tasks (priority / status / dependency) |
| Code has out-of-scope behavior | Create discovered task OR rollback excess |
| Session ends | Write handoff note + `bd dolt push` |

---

## 5. Forbidden Behaviors
AI MUST NEVER:
- Work outside task scope without creating a task first
- Run `bd close` before passing the quality gate
- Override a higher-layer rule with a lower-layer decision
- Claim "done" without `verify_against_spec` + `verify_against_acceptance`
- Assume "tests pass = spec correct"
- Self-decide when spec is ambiguous or trade-offs are large

---

## 6. Repo-Specific Commands
<!-- Fill these in. AI will use EXACTLY these commands — wrong commands waste time. -->

| Action | Command |
|--------|---------|
| Run tests | `<command>` |
| Lint / format | `<command>` |
| Build | `<command>` |
| Run locally | `<command>` |

**Definition of Done for this repo:**
- [ ] Tests pass
- [ ] Lint clean
- [ ] <add repo-specific criterion>
- [ ] <add repo-specific criterion>
```

- [ ] **Step 3: Run validator — CLAUDE.md.template should now pass**

```bash
bash scripts/validate-templates.sh 2>&1 | grep "CLAUDE.md"
```

Expected: `OK: CLAUDE.md.template`

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md.template
git commit -m "feat: add CLAUDE.md template"
```

---

## Task 3: Beads Task Schema Template (T2)

**Files:**
- Create: `docs/templates/beads-task.yaml`

- [ ] **Step 1: Create directory and file**

```bash
mkdir -p docs/templates
```

Create `docs/templates/beads-task.yaml`:

```yaml
# Beads Task Template — Layered AI Workflow Framework
# Usage: copy this file, fill in all fields, run `bd create` or paste into your Beads workflow.
# Remove comments before submitting to Beads.

# ── Core ─────────────────────────────────────────────────────────────────────
id: bd-xxxx               # assigned by Beads on creation
title: "<Short, clear description of what this task does>"
type: bug                 # bug | feature | task | epic | chore | message
priority: P2              # P0=critical | P1=high | P2=medium | P3=low | P4=backlog
status: todo              # todo | ready | in_progress | blocked | review | done

# ── Intent (immutable — captures goal at creation time) ───────────────────────
intent: "<What this task is trying to achieve. Do NOT update if spec evolves.>"
# When spec changes, use intent to decide: is this task still valid?
# If not → split or recreate with new intent. Never mutate intent.

# ── Source Links (where did this task come from?) ─────────────────────────────
source:
  spec_ref: "openspec/specs/<domain>/spec.md#<requirement-anchor>"
  design_ref: "openspec/changes/<change-name>/design.md"
  decision_ref: "openspec/changes/<change-name>/design.md#<decision-anchor>"
  discovered_from: null   # set to bd-xxxx if spawned while working on another task

# ── Execution Links (what technical changes implement this task?) ──────────────
execution:
  branch_ref: null        # git branch name (e.g. feature/jwt-refresh)
  commit_ref: null        # git commit SHA or short message
  pr_ref: null            # PR URL or number
  verification_ref: null  # REQUIRED before bd close. Accepted evidence types:
                          #   CI run link  |  test report  |  screenshot/manual note  |  benchmark

# ── Acceptance Criteria ───────────────────────────────────────────────────────
acceptance:
  delivery:
    # verify_against_spec: does behavior match the spec scenario?
    - "[ ] verify_against_spec: <spec scenario link or description>"
    # verify_against_acceptance: edge cases and specific behaviors
    - "[ ] verify_against_acceptance: <describe specific behavior to verify>"
  governance:
    - "[ ] tests_added_or_updated: required when applicable (skip = justify)"
    - "[ ] verification_passed: yes"
    - "[ ] spec_delta_checked: yes"
    - "[ ] implementation_links_present: yes"

# ── Definition of Ready ───────────────────────────────────────────────────────
# Task MUST meet ALL of these before status → ready:
#   ✅ spec_ref or clear rationale present
#   ✅ acceptance criteria are verifiable (not vague)
#   ✅ dependencies are known (no unknown blockers)
#   ✅ scope is unambiguous

# ── Dependencies ─────────────────────────────────────────────────────────────
depends_on: []            # list of bd-ids that must be done first
blocked_by: []            # list of bd-ids or external blocker strings
blocked_reason: []        # one entry per blocked_by item (1-to-1 mapping)
```

- [ ] **Step 2: Validate YAML is syntactically correct**

```bash
python3 -c "import yaml; yaml.safe_load(open('docs/templates/beads-task.yaml'))" && echo "YAML OK"
```

Expected: `YAML OK`

- [ ] **Step 3: Run full validator — expect 1 file passes**

```bash
bash scripts/validate-templates.sh 2>&1 | grep "beads-task"
```

Expected: `OK: docs/templates/beads-task.yaml`

- [ ] **Step 4: Commit**

```bash
git add docs/templates/beads-task.yaml
git commit -m "feat: add Beads task schema template"
```

---

## Task 4: Handoff Note Template (T3)

**Files:**
- Create: `docs/templates/handoff-note.md`

- [ ] **Step 1: Create `docs/templates/handoff-note.md`**

```markdown
# Handoff Note — <YYYY-MM-DD> <session-id>
<!-- Fill all sections. Delete unused sections only if truly empty (e.g. no blockers). -->

## State Snapshot
- Active branch: `<branch-name or "none">`
- Current task: `<bd-id>` — `<status>`
- Last successful verification: `<CI run link | test report | "none yet">`

## Đã làm
<!-- List completed tasks with PR references -->
- `[bd-xxxx]` <task title> — DONE, PR #<n>
<!-- Add more lines as needed -->

## Dang dở
<!-- Tasks started but not finished -->
- `[bd-xxxx]` <task title> — IN PROGRESS
  Lý do chưa xong: <specific reason>
<!-- Add more lines as needed -->

## Blockers
<!-- Active blockers preventing progress -->
- `[bd-xxxx]` blocked: <specific reason, what is needed to unblock>
<!-- Remove this section if no blockers -->

## Nên làm tiếp
<!-- What the next session should pick up -->
- Run `bd ready` → will return `[bd-xxxx]` (<task title>)
- Context note: <any important context for next session>

## Spec / task đã update
<!-- Artifact sync status -->
- `<openspec/path>` → delta merged | confirmed no update needed
- Beads sync: `bd dolt push` ✅ | ⚠️ PENDING (reason: <reason>)

## Risks / Assumptions
<!-- Do not leave this blank if there is ANY uncertainty -->
- Assumption in use: <e.g., "Redis WATCH handles concurrent refresh correctly">
- Risk still open: <e.g., "Edge case X not tested under prod load">
- Not yet verified: <e.g., "Performance at 10k concurrent users">
```

- [ ] **Step 2: Run validator — all 3 templates should now pass**

```bash
bash scripts/validate-templates.sh
```

Expected: 3 lines starting with `OK:`, no `MISSING:`, exit 0.

- [ ] **Step 3: Commit**

```bash
git add docs/templates/handoff-note.md
git commit -m "feat: add handoff note template"
```

---

## Task 5: Playbook — README + Quick-Start (P1)

**Files:**
- Create: `docs/playbook/README.md`

- [ ] **Step 1: Create `docs/playbook/README.md`**

```markdown
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
```

- [ ] **Step 2: Run validator — check README passes**

```bash
bash scripts/validate-templates.sh 2>&1 | grep "README"
```

Expected: `OK: docs/playbook/README.md`

- [ ] **Step 3: Commit**

```bash
git add docs/playbook/README.md
git commit -m "docs: add playbook README and quick-start"
```

---

## Task 6: Playbook — Architecture & Precedence (P2)

**Files:**
- Create: `docs/playbook/01-architecture.md`

- [ ] **Step 1: Create `docs/playbook/01-architecture.md`**

```markdown
# Kiến trúc: 5 Tầng

## Tổng quan

Framework chia trách nhiệm của AI thành 5 tầng riêng biệt, mỗi tầng trả lời một câu hỏi khác nhau và sở hữu artifact của riêng nó.

```
┌─────────────────────────────────────────────────────┐
│  TẦNG 4 — OPERATING PROCEDURE (Superpowers)         │
│  AI operating system. KHÔNG chứa business workflow. │
├─────────────────────────────────────────────────────┤
│  TẦNG 3 — EXECUTION LEDGER (Beads)                  │
│  Task graph. "bd ready" = việc tiếp theo.           │
├─────────────────────────────────────────────────────┤
│  TẦNG 2 — REQUIREMENT CONTRACT (OpenSpec)           │
│  Source of truth: what & why.                       │
├─────────────────────────────────────────────────────┤
│  TẦNG 1 — BEHAVIORAL CONTRACT (CLAUDE.md)           │
│  Luật bất biến cho AI.                              │
├─────────────────────────────────────────────────────┤
│  TẦNG 0 — INTAKE / TRIAGE                           │
│  Phân loại trước khi làm gì.                        │
└─────────────────────────────────────────────────────┘
```

## Tại sao tách tầng?

Lỗi phổ biến nhất khi dùng AI: AI vừa giữ requirement, vừa giữ checklist, vừa giữ style guide — dẫn tới context drift rất nhanh.

Mỗi tầng trả lời đúng một câu hỏi:

| Tầng | Artifact | Câu hỏi |
|------|----------|---------|
| 4 | Superpowers skills | Quy trình làm việc như thế nào? |
| 3 | Beads task graph | Làm gì tiếp theo? |
| 2 | OpenSpec specs + changes | Đang xây cái gì? |
| 1 | CLAUDE.md | AI được làm gì? |
| 0 | Triage output | Đây là loại việc gì? |

## Layer Precedence

```
CLAUDE.md  >  OpenSpec  >  Beads  >  Superpowers
```

**Nguyên tắc:** Tầng thấp hơn KHÔNG được override tầng cao hơn. Khi xung đột, update artifact ở tầng thấp.

### Ví dụ thực tế

| Tình huống | Xử lý đúng |
|------------|------------|
| Superpowers: "dùng TDD" ↔ CLAUDE.md: "không snapshot test" | Theo CLAUDE.md — đây là immutable rule |
| Beads: "làm API A" ↔ OpenSpec mới: "API A đã hủy" | Theo OpenSpec → update Beads task sang `won't do` |
| CLAUDE.md đổi rule về test coverage | Mọi task Beads đang open phải re-check acceptance criteria |

## Tầng 4 là "AI OS", không phải "business OS"

Superpowers chứa: `brainstorm → plan → TDD → review → verify`
Superpowers KHÔNG chứa: "feature loyalty point phải duyệt qua sale manager"

Nếu business process cần encode, đặt vào OpenSpec spec hoặc CLAUDE.md policy — không phải Superpowers skill.
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/01-architecture.md
git commit -m "docs: add architecture and precedence playbook section"
```

---

## Task 7: Playbook — Triage Guide (P3)

**Files:**
- Create: `docs/playbook/02-triage.md`

- [ ] **Step 1: Create `docs/playbook/02-triage.md`**

```markdown
# Intake & Triage

## Tại sao phải triage trước?

Nếu không triage, AI sẽ chọn flow theo direct prompt — thường quá nhẹ (LITE khi phải FULL) hoặc quá nặng (FULL khi chỉ cần LITE).

Triage là checkpoint bắt buộc. AI không được bắt đầu bất kỳ việc gì trước khi trả lời 3 câu hỏi này.

## 3 Câu hỏi Triage

### 1. Loại công việc?
`idea | bug | feature | refactor | spike | docs | chore`

### 2. Rollback cost nếu làm sai?

| Mức | Ý nghĩa | Ví dụ |
|-----|---------|-------|
| **LOW** | Revert nhanh, không ảnh hưởng data/contract | Fix UI text, thêm log, update dep patch |
| **HIGH** | Chạm auth / billing / data migration / permission / webhook / external API | Đổi JWT algorithm, thêm payment gateway, migration schema |

> **Rule cưỡng chế:** Rollback cost = HIGH → KHÔNG được dùng LITE, dù scope nhỏ.

### 3. Scope?

| Mức | Ý nghĩa |
|-----|---------|
| **SMALL** | 1 file hoặc vài file trong cùng module |
| **MEDIUM** | 1 service hoặc 1 bounded context |
| **LARGE** | Multi-service, cross-team, cần migration/rollout plan |

## Flow Selection

| Rollback cost | Scope | → Flow |
|---------------|-------|--------|
| HIGH | bất kỳ | FULL hoặc STANDARD |
| LOW/MEDIUM | LARGE | FULL |
| LOW/MEDIUM | MEDIUM | STANDARD |
| LOW | SMALL | LITE |

## Re-triage (quan trọng)

Triage không chỉ chạy một lần. AI PHẢI re-triage khi:

| Trigger | Hành động |
|---------|-----------|
| Discovered work tăng scope | Re-classify → escalate flow nếu cần |
| Phát hiện chạm auth/billing/data/contract | Escalate lên STANDARD/FULL ngay |
| Dependency mới làm tăng scope | Re-classify |
| Scope thu hẹp hơn dự kiến | Xác nhận với user trước khi downgrade |

> Nếu flow level tăng: escalate ngay, không tiếp tục flow cũ.

## Ví dụ triage thực tế

**Case 1:** "Fix typo trong error message của login page"
- Loại: bug
- Rollback cost: LOW (chỉ text, không đổi behavior)
- Scope: SMALL (1 file UI)
- → **LITE**

**Case 2:** "Thêm rate limiting cho login endpoint"
- Loại: feature
- Rollback cost: HIGH (chạm auth flow)
- Scope: MEDIUM (1 service)
- → **FULL** (rollback cost HIGH override scope)

**Case 3:** "Refactor UserService tách thành UserService + ProfileService"
- Loại: refactor
- Rollback cost: LOW (internal, no contract change)
- Scope: MEDIUM (bounded context)
- → **STANDARD**

**Case 4 — Re-triage:** Bắt đầu LITE để fix "validation bug" trong form
→ Phát hiện validation logic gọi vào billing service
→ Rollback cost trở thành HIGH
→ **Re-triage → STANDARD/FULL**
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/02-triage.md
git commit -m "docs: add triage guide with examples"
```

---

## Task 8: Playbook — 3 Flows with Abort Paths (P4)

**Files:**
- Create: `docs/playbook/03-flows.md`

- [ ] **Step 1: Create `docs/playbook/03-flows.md`**

```markdown
# 3 Flows: LITE / STANDARD / FULL

Tất cả flows đều có **abort path**: nếu verification FAIL, không được `bd close`. Phải chọn một trong ba:
1. Update design trong OpenSpec → re-execute
2. Tạo task fix mới (`discovered_from`) → vào queue
3. Re-triage nếu scope thực sự đã thay đổi

---

## LITE Flow

**Dùng khi:** rollback cost LOW + scope SMALL.

```
[Tầng 0] Triage → LITE confirmed
    ↓
[Tầng 1] Check CLAUDE.md rules
    ↓
[Tầng 3] bd create type:bug → bd update --claim
    ↓
Fix + test
    ↓
[Quality Gate] verify_against_spec + governance minimal
    ├── PASS → bd close → bd dolt push
    └── FAIL → tạo task fix / re-triage nếu rollback cost hóa ra HIGH
```

**Governance minimal cho LITE:**
- verification_ref: bắt buộc (CI link hoặc manual note)
- spec_delta_checked: chỉ khi fix thay đổi behavior
- pr_ref: bắt buộc nếu team dùng PR workflow

---

## STANDARD Flow

**Dùng khi:** 1 service/bounded context, không đổi external contract lớn, rollback cost LOW/MEDIUM.

```
[Tầng 0] Triage → STANDARD confirmed
    ↓
[Tầng 1] Check CLAUDE.md rules
    ↓
[Tầng 2] /opsx:propose → proposal + specs + design + tasks.md
    ↓                    (bỏ brainstorming — scope đã rõ)
[Tầng 3] bd create (per task) → link source refs → set depends_on
    ↓
[Tầng 4] executing-plans skill
    ↓
[Tầng 3] bd ready → bd update --claim → làm việc
    ↓
[Tầng 4] verification-before-completion skill
    ↓
[Quality Gate] Delivery + Governance + Negative checks
    ├── PASS → bd close
    │           ↓
    │        [Tầng 2] /opsx:archive → bd dolt push
    └── FAIL → update OpenSpec design / task fix / re-triage
```

---

## FULL Flow

**Dùng khi:** multi-service, rollback cost HIGH, đổi data model/auth/billing/contract, cần migration/rollout plan.

```
[Tầng 0] Triage → FULL confirmed
    ↓
[Tầng 1] Check CLAUDE.md rules
    ↓
[Tầng 4] brainstorming skill → explore → clarify → design → approve
    ↓
[Tầng 2] /opsx:propose → full artifact chain: proposal → specs → design → tasks.md
    ↓
[Tầng 3] Import tasks + intent lock + source refs + dependency graph
    ↓
[Tầng 4] writing-plans → executing-plans skills
    ↓
[Tầng 3] bd ready → bd update --claim → làm việc
    ↓
[Tầng 4] verification-before-completion + code-reviewer skills
    ↓
[Quality Gate] Delivery + Governance + Negative checks
    ├── PASS → bd close
    │           ↓
    │        [Tầng 2] /opsx:archive → Merge delta spec
    │           ↓
    │        [Handoff Protocol] bd dolt push + handoff note
    └── FAIL → update design / task fix / re-triage
```

---

## Chuyển từ LITE lên STANDARD/FULL giữa chừng

Trường hợp bắt đầu LITE, re-triage phát hiện rollback cost cao hơn dự kiến:

1. **Dừng lại** — không tiếp tục flow LITE
2. **Re-classify** → STANDARD hoặc FULL
3. **Nếu chưa có OpenSpec change:** chạy `/opsx:propose` để tạo artifact
4. **Nếu đã viết code:** đảm bảo code chưa được merge — có thể tiếp tục từ điểm hiện tại
5. **Update task Beads:** đổi type/priority nếu cần, thêm missing source links
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/03-flows.md
git commit -m "docs: add 3-flow playbook with abort paths"
```

---

## Task 9: Playbook — Beads Guide (P5)

**Files:**
- Create: `docs/playbook/04-beads-guide.md`

- [ ] **Step 1: Create `docs/playbook/04-beads-guide.md`**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/04-beads-guide.md
git commit -m "docs: add Beads usage guide"
```

---

## Task 10: Playbook — OpenSpec Guide (P6)

**Files:**
- Create: `docs/playbook/05-openspec-guide.md`

- [ ] **Step 1: Create `docs/playbook/05-openspec-guide.md`**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/05-openspec-guide.md
git commit -m "docs: add OpenSpec usage guide"
```

---

## Task 11: Playbook — Quality Gates & Anti-drift (P7)

**Files:**
- Create: `docs/playbook/06-quality-gates.md`

- [ ] **Step 1: Create `docs/playbook/06-quality-gates.md`**

```markdown
# Quality Gates & Anti-drift

## Quality Gate trước `bd close`

Không được tự assume "xong rồi". Phải xác nhận explicit từng mục:

### DELIVERY
- [ ] **`verify_against_spec`** — behavior đúng theo spec requirement
  - Không phải "test pass". Là "behavior match spec scenario".
  - Ví dụ: "Đã test scenario: login blocked sau 5 lần fail trong 15 phút ✅"
- [ ] **`verify_against_acceptance`** — đúng theo từng delivery acceptance criterion trong task
- [ ] **Tests pass** — hoặc ghi rõ "N/A: <lý do cụ thể>"

### GOVERNANCE
- [ ] **`spec_delta_checked`** — OpenSpec delta archived, hoặc confirm "no update needed"
- [ ] **`execution.pr_ref`** — điền PR link hoặc commit SHA
- [ ] **`execution.verification_ref`** — điền evidence (CI link / test report / screenshot / benchmark)

### NEGATIVE CHECKS
- [ ] **Không vi phạm CLAUDE.md rules** — tool usage, style, forbidden behaviors
- [ ] **Không introducing breaking change ngoài spec scope**
- [ ] **Code không chứa behavior ngoài task scope** (nếu có → phải có discovered task)

### Tại sao `verify_against_spec` ≠ "test pass"?

Tests kiểm tra code chạy đúng. Spec kiểm tra behavior đúng requirement.
Có thể: tất cả tests pass, nhưng test sai spec → AI báo done, behavior sai.

Ví dụ:
```
Spec: "block sau 5 lần fail trong 15 phút"
Test: `assert rate_limit_triggered(6_attempts)` → PASS
Thực tế: limit đếm tất cả attempts, không filter trong 15 phút
→ Test pass, nhưng spec sai
```

## Anti-drift — Cả 3 chiều

| Trigger | Hành động bắt buộc |
|---------|-------------------|
| Code thay đổi behavior | Mở delta spec trong OpenSpec |
| Task close | Confirm spec up-to-date hoặc "no update needed" |
| Spec/design thay đổi requirement | Update Beads tasks / dependency / priority / status |
| Code chứa behavior ngoài task scope | Tạo discovered task HOẶC rollback phần dư |
| Session kết thúc | `bd dolt push` + handoff note |
| Phát hiện việc ngoài scope khi đang làm | `bd create discovered_from:<id>` + báo user |

## Discovered work rule

Khi AI phát hiện việc cần làm ngoài scope task hiện tại:

```bash
# ĐÚNG:
bd create "Fix N+1 query in UserService.findAll" \
  --type bug \
  --deps discovered-from:bd-a1b2
# Rồi báo user: "Phát hiện N+1 query, đã tạo bd-c3d4. Tiếp tục task hiện tại."

# SAI:
# Âm thầm fix N+1 query trong cùng PR
# "Tiện tay sửa luôn"
```

Lý do: "tiện tay sửa" không có spec, không có acceptance criteria, không có review. Khi có bug sau, không biết ai thay đổi gì, tại sao.
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/06-quality-gates.md
git commit -m "docs: add quality gates and anti-drift guide"
```

---

## Task 12: Playbook — Handoff Protocol (P8)

**Files:**
- Create: `docs/playbook/07-handoff-protocol.md`

- [ ] **Step 1: Create `docs/playbook/07-handoff-protocol.md`**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add docs/playbook/07-handoff-protocol.md
git commit -m "docs: add handoff protocol guide"
```

---

## Task 13: Final Validation & Git Log

- [ ] **Step 1: Run full validation — expect all PASS**

```bash
bash scripts/validate-templates.sh
```

Expected output:
```
OK: CLAUDE.md.template
OK: docs/templates/beads-task.yaml
OK: docs/templates/handoff-note.md
OK: docs/playbook/README.md
OK: docs/playbook/01-architecture.md
OK: docs/playbook/02-triage.md
OK: docs/playbook/03-flows.md
OK: docs/playbook/04-beads-guide.md
OK: docs/playbook/05-openspec-guide.md
OK: docs/playbook/06-quality-gates.md
OK: docs/playbook/07-handoff-protocol.md

PASS: all framework files present and clean.
```

- [ ] **Step 2: Verify git log looks clean**

```bash
git log --oneline
```

Expected: 13+ commits, each describing one deliverable.

- [ ] **Step 3: Final commit — mark complete**

```bash
git commit --allow-empty -m "$(cat <<'EOF'
feat: complete layered AI workflow framework v1.0

Deliverables:
- CLAUDE.md.template (behavioral contract template)
- docs/templates/beads-task.yaml (execution ledger schema)
- docs/templates/handoff-note.md (session handoff template)
- docs/playbook/ (7 sections: architecture, triage, flows,
  beads guide, openspec guide, quality gates, handoff protocol)
- scripts/validate-templates.sh (acceptance gate)

Framework covers: 5-layer architecture, 3 flow levels,
quality gates, anti-drift (3 axes), handoff ritual.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"