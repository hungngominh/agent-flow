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
