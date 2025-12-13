---
trigger: always_on
---

## Single Responsibility & Controller Cleanliness

This codebase follows an extremely high standard for **single responsibility** and **clarity of flow**.
Controllers are not a place for business logic, complex branching, or ad-hoc error handling.

you are an expert *Staff-Level developer* with a high quality standard: The goal is simple: **clean controllers, explicit services, predictable responses**.

---

## 1. Error Handling (Explicit, Custom, Discoverable)

Errors must be handled with **clarity** and **custom error classes**.

### Custom Errors Location

Errors must live under a clear, domain-oriented path:

`app/errors/<domain>/<error_name>.rb`


Example:

```
app/errors/books/not_performable_action.rb
```

Use this kind of error when an action cannot be executed due to:
- Business rules
- Domain validation
- Forbidden state transitions

Errors must be named by intent, not by technical symptoms.

### Centralized Rescue Policy

Controllers must not be filled with `begin/rescue` blocks.

Instead, define a **shared rescue helper** included in `ApplicationController` that centralizes:

- `rescue_from` mappings
- Status codes
- Standard response shape
- Consistent error payload formatting

This is guided by a **“let it break” philosophy**:
- Raise meaningful domain errors
- Rescue them at the boundary (controller layer)
- Keep controllers clean and linear

---

## 2. Controller Flow (Minimal, Memoized, No Callback Abuse)

Controllers must remain thin and readable.

### Memoization Rule (Preferred Over before_action)

Whenever a record lookup is needed, prefer memoization:

```rb
def book
  @book ||= Book.find_by(id: params[:id])
end
```

This is prioritized over:

```rb
before_action :set_book
```

Why: memoization keeps the logic close to where it is used, reduces indirection, and improves readability.

### 3. Business Logic Must Live in Service Classes

Controllers must delegate business logic to service classes.

#### Interactor Standard
Services must use the `interactor` gem and be split into:

BaseService → for `interactors` (single responsibility operations)

BasePipeline → for `organizers` (multi-step flows / orchestration)

This ensures predictable structure and keeps orchestration separate from execution.

### 4. Request Services Must Use RequestEntryPoint Namespace

Every request-driven operation must enter the system through:

```ruby
RequestEntryPoint::<RequestServiceActionName>
```

This namespace is the single “front door” for request actions.

Examples:
```rb
RequestEntryPoint::CreateBook

RequestEntryPoint::UpdateBook

RequestEntryPoint::Books::Archive
```

The controller should call entrypoints, not deep internal interactors directly.

### 5. Serialization Standard (Blueprinter Only)

All serializers must be implemented with Blueprinter.

Rules:

Every serialized entity must include a `data_type` attribute.
Serialization must be consistent across the API.

### 6. Response Contract (Always { data:, errors: })
All API responses must follow this contract:

```json

{ "data": ..., "errors": ... }
```
Rules:

data must always exist:

Object response: data: `{}`

Collection response: data: `[]`

errors must always exist:

No errors: errors: `[]`

Error response: errors: `[{ ... }]`

This is non-negotiable. Consistency is a feature.

## Applicability Rule (Quality First)

All rules above must be applied only if:

- They are feasible in the current context, and
- They clearly improve code quality, clarity, and maintainability.
- No cargo-cult patterns. Only intentional architecture.

## Summary Checklist (Required After Changes)
 - [ ] Domain errors implemented as custom errors under app/errors/...
 - [ ] Error handling centralized via rescue_from helper in ApplicationController
 - [ ] Controllers kept clean and linear (“let it break” flow)
 - [ ] Record fetching done via memoization (@book ||= ...) where applicable
 - [ ] Business logic moved to Interactor-based services (BaseService / BasePipeline)
 - [ ] Request actions routed through `RequestEntryPoint::<ActionName>`
 - [ ] Serialization implemented with Blueprinter, including type
 - [ ] Responses always follow { data:, errors: } with correct shapes
