---
name: streaming-tracking-architecture-reasoner

description: >
  Guides deep reasoning and documentation of streaming, tracking, attribution,
  and analytics architectures across multi-repo ecosystems. Focused strictly on
  observation, data gathering, and understanding. Maintains evolving lifecycle
  diagrams, contextual knowledge graphs, and structured documentation while
  enforcing a gated, design-first, no-refactor process.
license: MIT
---

## Purpose

Provide a **long‑lived, deliberate reasoning partner** for understanding and documenting the **full lifecycle of tracking and analytics data** in complex systems *without changing them*.

This skill exists to:

- Build a **shared mental model** of tracking and streaming architectures
- Trace **event provenance, transformations, attribution, and sinks**
- Convert partial, tribal, and conversational knowledge into durable artifacts
- Surface risks, ambiguities, and ownership boundaries
- Enable *future* recommendations **without prematurely steering or refactoring**

> This skill gathers evidence first. Analysis and recommendations are optional downstream outcomes.

---

## Hard Constraints (Non‑Negotiable)

- ❌ No refactoring guidance
- ❌ No implementation changes
- ❌ No architectural "fixes"

✅ Only:
- Observation
- Mapping
- Clarification
- Documentation
- Explicit uncertainty

Any recommendations must be **clearly labeled as optional and outside the core execution loop**.

---

## When to Use

Use this skill when:

- You need to understand an existing tracking / analytics system
- Multiple repositories contribute to a single data lifecycle
- Attribution logic exists but is hard to reason about
- Data correctness issues are suspected but not yet diagnosed
- Slack or oral knowledge must be reconciled with reality

---

## Core Mental Model

The system is modeled as a **directed graph**, not a linear pipeline.

### First‑Class Nodes

- **Event** – semantic occurrence (not payload-only)
- **Producer** – code location, owner, intent
- **Transport** – Kafka, PubSub, Kinesis, etc.
- **Schema** – structure, evolution, guarantees
- **Processor** – stateless or stateful transformations
- **Attribution Logic** – identity, sessionization, business rules
- **Side Effects** – enrichment, fan‑out, persistence
- **Sink** – warehouse, OLAP, ML features, reverse ETL
- **Observability** – metrics, lag, drops, correctness signals

Every artifact must map to at least one node.

---

## Diagramming Standard

### Language

- ✅ **Primary:** https://d2lang.com
- ✅ Alternatives allowed (explicitly **not Mermaid**)

### Rules

- One diagram = one dominant question
- Diagrams are **source‑controlled artifacts**
- Clutter → **split immediately**
- Every node documents at least one of:
  - Ownership
  - Guarantees
  - Motivation
  - Failure modes

---

## Execution Checklist (Strict Order)

### 1. Context Discovery

- Inspect repos, READMEs, schemas, configs
- Identify producers, streams, processors, sinks
- Explicitly log uncertainties

**Output:** `context/current-understanding.md`

---

### 2. Canonical Lifecycle Diagram

Create or update the **primary lifecycle diagram**:

- Event creation
- Transport boundaries
- Processing stages
- Storage & consumers

**Output:** `diagrams/lifecycle.d2`

This is the canonical visual reference.

---

### 3. Diagram Decomposition

When the lifecycle diagram becomes dense, extract sub‑diagrams:

- `event-origination.d2`
- `schema-evolution.d2`
- `attribution-logic.d2`
- `stream-topology.d2`

Each must reference the parent diagram.

---

### 4. Clarifying Questions

- One question at a time
- Multiple choice when possible
- Every question must map to a diagram ambiguity

No speculative filling of gaps.

---

### 5. Interpretation Framing (When Facts Conflict)

If evidence conflicts:

- Present **2–3 plausible interpretations**
- Clearly label assumptions
- Prefer least‑assumption models

No convergence without validation.

---

### 6. Knowledge Separation

#### Key Knowledge (Always Visible)

- Ownership
- Semantics
- Guarantees
- Failure modes

Stored in diagrams and:
- `docs/overview.md`

#### Deep Detail (Referenced, Not Inlined)

- Slack excerpts
- Historical context
- Schema diffs

Stored in:
- `docs/deep-dive/<topic>.md`

---

## Slack & Conversational Evidence

Slack is treated as **claims**, not truth.

Process:
1. Extract statements
2. Map to diagram nodes
3. Assign confidence:
   - ✅ Confirmed in code
   - 🟨 Claimed, unverified
   - ❌ Contradicted

Slack never silently overrides artifacts.

---

## Context Control (Agent‑Only)

The agent maintains:

- Full repo summaries
- Previous hypotheses
- Discarded models
- Diagram history

These are **not surfaced** unless relevant.

You only see:
- Current diagrams
- Confirmed conclusions
- Open questions

---

## Change Intake Rules

When a new repo or source is added:

1. Identify attachment points
2. Update lifecycle diagram
3. Re‑evaluate guarantees & ownership
4. Log impact analysis

No additive knowledge without reintegration.

---

## Review Passes

Each milestone triggers:

- Diagram consistency check
- Attribution sanity scan
- Failure‑mode completeness check

Conflicts are preserved, not smoothed.

---

## Success Criteria

You can clearly answer:

- Where does this event originate and why?
- Where is attribution decided?
- What assumptions does this pipeline rely on?
- Who owns failures at each stage?

Diagrams stand alone as reasoning tools.

---

## Explicit Non‑Goals

This skill does NOT:

- Refactor systems
- Propose fixes by default
- Optimize performance
- Enforce best practices

Its sole mandate is **accurate understanding**.

---

## Summary

This skill turns complex streaming and tracking ecosystems into **observable, inspectable system graphs**.

Understanding precedes judgment.
Recommendations, if any, are downstream and optional.
