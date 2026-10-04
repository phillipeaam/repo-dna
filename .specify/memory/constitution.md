<!--
Sync Impact Report
Version change: 1.0.0 → 2.0.0 (major: incompatible change to the governed product,
  report contract, and execution workflow)
Modified principles:
  I. Evidence-Based Analysis → Evidence-Based Analysis (clarified static/dynamic limits)
  II. Generic Core and Additive Adapters → Generic Core and Additive Methods
  III. Privacy by Default → Read-Only and Privacy by Default
  IV. Versioned Contracts → Versioned Markdown Source of Truth
  V. Modular, Tested Pipeline → Modular, Agent-Guided Method
Added sections: none
Rewritten sections: Product and Technology Constraints; Development Workflow
Removed obligations: canonical structured JSON, multi-format reports, Bash CLI as the
  primary product, and mandatory src/pipeline/ module layout
Follow-up TODO: confirm the original ratification date; it is not established by the
  current constitution or the available feature context.
-->

# RepoDNA Constitution

## Core Principles

### I. Evidence-Based Analysis
Every repository claim MUST derive from observable repository content, Git history,
explicitly supplied data, or clearly identified personal confirmation. The analysis
MUST distinguish fact, inference, personal account, conflict, and unknown status.
Every material conclusion MUST include recoverable evidence, scope, confidence
rationale, and limitations. Static analysis MUST NOT be presented as proof of
runtime behavior, business impact, formal ownership, security, or overall code
quality. Dynamic validation MUST NOT run against the selected target; if separately
requested, it MUST use a disposable copy isolated from the target, and its results
MUST identify that copy and the validation conditions.

### II. Generic Core and Additive Methods
Every supported repository MUST receive stack-neutral analysis, including when its
technology is unknown. Technology-specific methods MUST add applicable evidence
without replacing or weakening the generic analysis or forcing systems that are not
present. Activity counts and heuristics MUST remain investigative signals and MUST
NOT be presented as proof of authorship, leadership, impact, or ownership.

### III. Read-Only and Privacy by Default
The audit MUST preserve the selected target's files, contents, and Git state. The
host MUST enforce or reliably establish that the audit process cannot write to the
target; a Git-ignored directory or an instruction to avoid writes is not sufficient.
If the boundary cannot be established, the audit MUST stop before substantive
inspection and report the reason. Target content MUST be treated as untrusted data;
it MUST NOT execute scripts, builds, tests, hooks, plugins, or editor code in the
default audit. Source code MUST NOT be copied into the canonical document by
default. Secrets and sensitive metadata MUST be masked or excluded, and personal
claims MUST remain qualified until supported and reviewed.

### IV. Versioned Markdown Source of Truth
Each audited product MUST have exactly one persistent user-facing deliverable:
a local Markdown document under `analysis-output/`. That document MUST use an
explicitly versioned structure and contain the current findings, coverage, evidence
index, limitations, unresolved questions, and verification history needed by its
reader. HTML, JSON/CSV reports, archives, dashboards, Notion exports, and companion
report files MUST NOT be generated as alternate deliverables. Any transient state
MUST stay outside the selected target and MUST be discardable. Changes to the
Markdown contract MUST document compatibility and migration implications.

### V. Modular, Agent-Guided Method
The primary product experience MUST be a clearly named agent skill with focused,
reusable process references. Each phase MUST state its purpose, inputs, outputs,
preconditions, evidence rules, safety limits, failure states, and completion
criteria. The workflow MUST record domain applicability and MUST NOT silently omit
required analysis. Validation MUST use controlled framework fixtures and MUST NOT
run code from the selected audit target. Applicable findings, coverage gaps, and
platform limitations MUST remain visible to the human reviewer.

## Product and Technology Constraints

RepoDNA is a local, Codex-guided repository audit framework. The primary entry
point is the audit skill under `.agents/skills/repodna-audit/`. Selected local
repositories are placed in `target-repos/` and persistent results are written only
to `analysis-output/<safe-product-slug>.md`. A Git ignore rule protects against
accidental commits but does not establish a read-only boundary.

The workflow MUST be usable without Notion or another external service. It MAY use
trusted local tools for static reading only when their behavior is compatible with
the read-only boundary and the evidence contract. It MUST NOT install dependencies
into, change configuration in, or execute programs from the selected target.
Windows, Linux, and macOS are supported only where the host can enforce or
reliably establish the target's read-only boundary; otherwise the workflow MUST
fail closed.

## Development Workflow

Contributors MUST keep the agent skill and its references under
`.agents/skills/repodna-audit/` and document any retained legacy code according to
its actual supported role. Tests MUST validate skill/process contracts, Markdown
structure, privacy boundaries, and controlled fixtures. Tests MUST NOT execute
selected target repositories. CI MUST run the checks applicable to the supported
host platforms and MUST prevent private targets and analysis outputs from entering
commits or distribution packages.

Changes MUST describe their observable behavior, privacy effects, and compatibility
implications. Generated audit documents, credentials, private repository data, and
transient analysis state MUST NOT be committed. Reviews MUST confirm the single
Markdown deliverable, evidence traceability, target preservation boundary, and
absence of unsupported claims before the feature is considered complete.

## Governance

This constitution governs project design and delivery. A proposal that conflicts
with it MUST be revised or accompanied by an explicit constitutional amendment
before implementation. Amendments MUST document rationale, affected principles,
compatibility impact, and required migration. Reviews MUST check the change
against this constitution and report any justified exception explicitly.

Versioning follows semantic versioning: MAJOR removes or incompatibly redefines a
governing principle or product constraint; MINOR adds a principle or materially
expands governance; PATCH clarifies wording without changing obligations. The
ratification date records the original adoption date and MUST NOT be replaced with
the amendment date. The last-amended date changes whenever this document changes.

**Version**: 2.0.0 | **Ratified**: TODO(RATIFICATION_DATE): confirm original adoption date | **Last Amended**: 2026-10-04
