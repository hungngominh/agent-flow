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
