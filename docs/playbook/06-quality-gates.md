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
