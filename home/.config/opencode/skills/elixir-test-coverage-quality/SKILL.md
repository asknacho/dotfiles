---
name: elixir-test-coverage-quality

description: 'Reviews Elixir test suites for quality, coherence, and effectiveness. Evaluates alignment with the Testing Pyramid, Elixir/OTP best practices, and coherent testing theory. Focuses on intent-driven coverage, fast feedback, avoidance of redundancy, and meaningful confidence rather than raw coverage percentage.'
license: MIT
---

# Elixir Test Coverage Quality Reviewer

## Overview

Evaluate whether an Elixir codebase has **coherent, maintainable, and risk-aligned test coverage**. This skill prioritizes **confidence per test**, fast feedback, and clear intent over exhaustive or mechanically inflated coverage metrics.

It combines:
- The **Testing Pyramid** (unit → integration → end-to-end)
- **Elixir and OTP testing best practices**
- **Coherent testing theory** (intent alignment, redundancy avoidance)

Use this skill during PR review, CI quality checks, or architectural audits of test suites.

---

## When to Use

Use this skill when:

- Reviewing test coverage in an Elixir or Phoenix project
- A PR adds or modifies tests
- Coverage numbers increase but confidence feels unchanged
- Tests are slow, brittle, or hard to understand
- You want to rebalance unit vs integration vs E2E tests
- The question is “do these tests actually help us?”

---

## Core Testing Principles

### The Foundational Rules

1. **Confidence > Coverage**  
   Coverage percentage is a lagging indicator. Tests exist to reduce risk.

2. **Intent Over Mechanics**  
   Every test should answer *what could break and why*.

3. **Layer Discipline**  
   A test must clearly belong to one layer (unit, integration, E2E).

4. **Fast Feedback**  
   The majority of tests must run in milliseconds.

5. **Failure Clarity**  
   A failing test should explain the defect without reading the code.

### When NOT to Add Tests

```
- To increase coverage percentage only
- When asserting implementation details
- When lower layers already guarantee the behavior
- When failure risk is negligible
- When tests would be slower and less precise than existing ones
```

---

## The Testing Pyramid (Required Shape)

### 1. Unit Tests (Base Layer)

**Purpose:** Validate pure logic and business rules.

✅ Expectations:
- Test pure functions directly
- No database, filesystem, or network access
- Majority of the test suite lives here
- Fast, deterministic, and isolated

🚫 Red Flags:
- Testing private functions
- Asserting internal data structures
- Duplicating unit logic in higher layers

---

### 2. Integration Tests (Middle Layer)

**Purpose:** Validate boundaries and collaboration.

✅ Expectations:
- Use real Ecto Repo with sandbox
- Validate schema constraints and changesets
- Test GenServer behavior via observable effects
- Test supervision restarts only if failure matters

🚫 Red Flags:
- Re-testing business logic already covered by unit tests
- Order-dependent tests
- Heavy reliance on global mocks

---

### 3. End-to-End Tests (Top Layer)

**Purpose:** Validate critical user flows only.

✅ Expectations:
- Few and intentional
- Express high-level behavior (auth, payments, data integrity)
- No duplication of unit or integration assertions

🚫 Red Flags:
- Driving overall coverage confidence
- Checking business rules already tested below
- Large E2E suite used as safety net

---

## Elixir-Specific Best Practices

### Pure Logic & Context Design

✅ Good Practices:
- Business logic isolated from IO
- Context modules encapsulate decisions
- Side effects live at boundaries

🚫 Anti-Patterns:
- Mixing Repo calls with complex conditionals
- Controller-heavy logic coverage

---

### Pattern Matching

✅ Good Practices:
- Tests validate semantic behavior
- One test per distinct behavior, not per clause

🚫 Anti-Patterns:
- Clause-by-clause testing
- Tests that mirror function heads exactly

---

### OTP & Processes

✅ Good Practices:
- Test GenServers via public API and messages
- Test supervision only for meaningful recovery behavior

🚫 Anti-Patterns:
- Inspecting internal GenServer state
- Using `Process.sleep/1` for assertions

---

## Edge Case Strategy

### When Edge Cases ARE Required

- Invalid or unexpected external input
- Boundary values with business significance
- Error tuples from dependencies
- Concurrency or ordering risks

### When Edge Cases Are Overkill

```
- Every guard clause
- Every pattern match branch
- Property tests with low defect yield
- Defensive testing with no realistic failure mode
```

---

## Coherence & Intent Checks

### Test Coherence Rules

1. **No Redundant Assertions Across Layers**  
   If a unit test guarantees it, higher layers must not repeat it.

2. **Semantic Alignment**  
   Each test must map to an invariant, requirement, or risk.

3. **Intentional Naming**  
   Test descriptions explain *why*, not *how*.

---

## Coverage Interpretation Guidelines

✅ Healthy Signals:
- Near-complete coverage of core decision logic
- Explicit testing of failure paths
- Low coverage tolerated in trivial glue code

🚫 Misleading Signals:
- High coverage driven by E2E tests
- Numeric thresholds treated as goals
- Snapshots or broad asserts hiding intent

> Coverage is a **measurement**, not a **goal**.

---

## Review Outcomes

### ✅ Success

- Fast, readable tests
- Clear pyramid shape
- High confidence with minimal redundancy

### ⚠️ Warnings

- Pyramid imbalance
- Tests exist but intent is unclear
- Redundant cross-layer assertions

### ❌ Failure

- Confidence relies on slow test layers
- Coverage is incoherent or mechanical
- Tests increase maintenance cost without reducing risk

---

## Reviewer Recommendations

### Suggest Removing

- Tests that duplicate behavior across layers
- Implementation-detail assertions
- Slow tests covering low-risk logic

### Suggest Adding

- Unit tests for untested decision logic
- Targeted integration tests at real boundaries

### Suggest Refactoring

- Improve test naming and structure
- Rebalance coverage toward unit tests
- Simplify overgrown integration suites

---

## Quick Review Checklist

### Pyramid Health

- [ ] Unit tests dominate the suite
- [ ] Integration tests validate real boundaries
- [ ] E2E tests are minimal and critical-only

### Test Quality

- [ ] Each test has clear intent
- [ ] No redundant assertions across layers
- [ ] Failures are easy to interpret

### Elixir / OTP Practices

- [ ] Pure logic isolated
- [ ] GenServers tested via behavior
- [ ] Repo usage tested with sandbox

---

## Summary

This skill explicitly resists **coverage maximalism**.

It rewards:
- Intentional tests
- Layer discipline
- High signal-to-noise ratio
- Confidence-driven design

Use it to decide **what should be tested**, **where**, and **why**—not merely *how much*.
