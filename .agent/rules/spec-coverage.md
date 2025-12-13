---
trigger: always_on
---

## Testing Rules (Staff-Level Quality)

Tests are not a formality in this codebase. They are part of the product.

You are a **Staff-level developer**: you write specs that are **clear, resilient, readable, and reusable**. Every spec should teach the next engineer how the system behaves.

### Core Principle

Only apply these requirements **when they are feasible and truly improve quality and understanding**.
Avoid “testing architecture” for its own sake.

## RSpec Standards

### 1. Factory Usage (Consistency Over Cleverness)

When using factories:

- Prefer **coherent traits** over one-off factory variations.
- Keep traits **named by intent**, not by implementation details.
  - ✅ `:with_primary_contact`, `:with_disbursement_plan`
  - ❌ `:with_foo_flag_true`, `:special_case_12`
- Avoid over-building records. Create only what the spec needs.
- Keep factory definitions organized and easy to scan.

If a trait starts to represent a reusable scenario, it should be treated as part of the testing API.

### 2. Shared Contexts (Reusable Testing API)

Shared contexts are allowed **only when they improve organization and reduce duplication**.

Rules:

- Do **not** introduce shared contexts unless they clearly:
  - Reduce repeated setup
  - Improve readability
  - Provide a stable “testing API” that multiple specs can reuse
- Shared contexts must live under:

  `spec/shared/context/<shared_context_name_id>.rb`

- Shared context names must be stable IDs (snake_case), easy to reuse:
  - Example: `spec/shared/context/authenticated_user.rb`
- Shared contexts must be called consistently:

```rb
  it_behaves_like "authenticated_user"
```

Shared contexts must be written to feel like a small, predictable contract:
- Minimal inputs
- Clear assumptions
- Explicit outputs (what state they create)

### 3. Document Shared Contexts (Tips Section)

If you add or modify shared contexts, you must document them in the README under a Tips section.

Include:
- Shared context ID
- Purpose
- Required inputs (if any)
- What it sets up / guarantees

Example documentation entry format:

- `authenticated_user`: logs in a user and exposes `current_user` + auth headers
- `with_builder_lead`: creates a builder lead with required associated records

### 4. Request Specs (Swagger Coverage + Error Handling)

Request specs must be treated as contract tests.

Rules:

- Use Swagger (rswag) for request specs when it is available in the project.
- Ensure endpoints have:
    - Happy path coverage
    - Authorization coverage (when applicable)
    - Validation / error cases
    - Proper status codes
    - Clear and consistent response bodies
- Any new endpoint must include:
    - Documentation
    - Examples
    - Failure modes (not just success)

Swagger specs should not be “decorative”—they must reflect real behavior and protect the API.

### 5. Quality Bar (Definition of Done)

A change is not complete unless tests are:
- Easy to read without extra context
- Stable (not flaky, not order-dependent)
- Minimal (no unnecessary setup)
- Intent-focused (tests describe behavior, not implementation)

### Summary Checklist (Required After Changes)

After updating or adding specs, include a checklist summary:

- [ ]  Factories and traits are coherent and minimal
- [ ] Shared contexts used only when they improve clarity
- [ ] Shared contexts placed under `spec/shared/context/`
- [ ] Shared contexts documented in README Tips (if added/changed)
- [ ] Request specs include Swagger coverage (when available)
- [ ] Error handling and failure modes are covered
