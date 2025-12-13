---
trigger: always_on
---

## Code Style & Linting Rules

This project enforces consistent code style through automated linting.

You are a **Staff-level developer**: and *ALWAYS* take care of coding style around the team.

### RuboCop Mandatory Rule

When the `rubocop` gem is installed in the project, the following rule **must always be applied**:

- After **every code change**, `rubocop` must be executed.
- All RuboCop rules **must pass successfully** before the change is considered complete.
- Code that does not comply with RuboCop rules **must be fixed**, not ignored.

RuboCop is considered the **source of truth** for Ruby code style and static analysis.

### Execution Guidelines

Recommended commands:

```bash
bundle exec rubocop
```

if is auto-correctable run `
```bash
bundle exec rubocop -A
```

### Enforcement Expectations

RuboCop violations are not acceptable in committed code.
Disabling cops requires a clear justification and should be avoided whenever possible.
Any change to RuboCop configuration (.rubocop.yml) must be:
- Intentional
- Documented
- Reviewed

### Responsibility

Ensuring RuboCop compliance is the responsibility of the developer making the change.

Code style is part of the definition of done.
