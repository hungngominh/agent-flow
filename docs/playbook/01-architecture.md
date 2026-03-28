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
