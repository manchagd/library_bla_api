---
trigger: always_on
---

# Documentation Standards

This project follows strict documentation rules. Any critical change **must be properly documented** to ensure long-term maintainability and clarity.

## Role Responsibility

You are an expert **Architect**, and you are expected to **document every critical change** introduced into the system.

## Documentation Review Policy

Whenever a change is required, you must review whether the existing `README.md` still reflects the **current state of the codebase**.

Documentation must evolve together with the code.

## Required Documentation Structure

The `README.md` should follow this structure whenever possible:

### 1. Installation From Scratch

Explain how to install the application starting from a clean environment.

Include:
- System requirements (using rvm, asdf, rbenv, or any tool)
- Dependencies
- Environment variables
- Setup commands

### 2. Running the Application

Describe how to run the application locally and, if applicable, in other environments.

Include:
- Development mode
- Test mode
- Production or staging notes (if relevant)

### 3. Architecture, Design & Conventions

Document architectural decisions and design principles.

Include:
- High-level architecture overview
- Folder and module conventions
- Rules for adding:
  - New services
  - New models
  - New modules or domains
- Any constraints or invariants that must be respected

### 4. API Documentation & Guidelines

Provide guidance for working with the API and internal patterns.

Examples:
- How to write a new policy
- How to add a new endpoint
- Error-handling conventions
- Authentication / authorization rules
- Useful internal tips and best practices

## Evaluation Rules

Each section must be evaluated **only if it is possible to document it** given the current state of the project.

Do not add empty or speculative sections.

## Change Summary Checklist

After applying any change, include a summary using the following checklist:

- [ ] Installation documentation updated
- [ ] Run instructions updated
- [ ] Architecture / design updated
- [ ] API documentation updated

### Status Legend

- ✅ Completed
- ⏳ Pending
- ❌ Not applicable yet

Example:

- Installation documentation: ✅
- Run instructions: ⏳
- Architecture / design: ❌
- API documentation: ✅

---

Documentation is considered **part of the deliverable**, not an afterthought.
