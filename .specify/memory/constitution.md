<!--
Sync Impact Report
Version change: unratified scaffold → 1.0.0 (initial constitution)
Modified principles: five empty principle placeholders → Evidence-Based Analysis;
  Generic Core and Additive Adapters; Privacy by Default; Versioned Contracts;
  Modular, Tested Pipeline
Added sections: Product and Technology Constraints; Development Workflow
Removed sections: none
Follow-up TODO: confirm the original ratification date.
-->

# RepoDNA Constitution

## Core Principles

### I. Evidence-Based Analysis
Every repository claim MUST derive from observable repository content, Git history,
explicitly supplied data, or personal confirmation. Reports MUST distinguish facts
from inferences and include confidence, evidence, limitations, or an explicit
unknown status. Static analysis MUST NOT be presented as proof of runtime behavior,
business impact, formal ownership, security, or overall code quality.

### II. Generic Core and Additive Adapters
Every supported repository MUST receive the stack-neutral generic analysis, even
when its technology is unknown. Technology-specific adapters MUST add evidence
without replacing or weakening the generic dataset. Adapters MUST consume the
shared structured contracts and MUST NOT introduce stack-specific conditions into
generic analysis.

### III. Privacy by Default
Source code MUST NOT be exported by default. Strict privacy mode MUST disable
source export, redact sensitive metadata, and block unsafe archives when privacy
scans fail. Secret findings MUST contain masked values only. Exclusions and
allowlists MUST never require storing raw secret values. Personal ownership and
impact claims MUST remain unapproved until explicitly confirmed.

### IV. Versioned Contracts
Machine-readable reports, schemas, snapshots, health scores, and hotspot models
MUST have explicit versioned contracts. Breaking changes MUST increment the
relevant major contract version or provide a documented migration path. Changes
to a metric's meaning MUST update its model version and supporting methodology
documentation. Optional or unavailable evidence MUST expose its assessment state
instead of silently appearing equivalent to validated evidence.

### V. Modular, Tested Pipeline
Production code MUST remain in its documented layer and dependency direction.
Each `src/pipeline/` module MUST declare one public function, perform no work when
sourced, write only inside the current report directory, and return non-zero for
unrecoverable failures. `dna-analysis.sh` MUST make execution order explicit.
Bug fixes MUST include regression coverage, and changes to shared contracts MUST
include contract coverage.

## Product and Technology Constraints

RepoDNA is a local-repository analyzer implemented as a Bash CLI with Python
collectors and renderers. The canonical report model is structured JSON; HTML,
CSV, charts, archives, and integrations MUST derive from that model rather than
independently reinterpreting repository contents. Reports MUST work offline after
generation and validate against packaged, versioned schemas.

The supported runtime baseline is Bash 4.3 or newer and Python 3.11 or newer.
Git Bash is the documented Windows shell. Optional language parsers and charting
dependencies MUST have an explicit fallback or unavailable status. Specialized
adapters provide static evidence; they do not promise compilation, dependency
installation, test execution, packaging, deployment, editor import, or application
startup.

## Development Workflow

Contributors MUST follow `docs/architecture.md` and keep source, collectors,
renderers, and tests in their documented locations. Changes MUST remain focused
and describe observable behavior changes, privacy effects, and compatibility
implications. Generated reports, archives, credentials, and private repository
data MUST NOT be committed.

Before merge, changes MUST pass applicable unit, contract, and integration checks.
The complete local validation command is `bash ./tests/run.sh`; patches MUST also
pass `git diff --check`. Every bug fix MUST include a regression test. Detector
changes MUST cover priority and preferred-root cases, privacy changes MUST cover
standard and strict modes, and report changes MUST be driven by structured JSON
fixtures. CI MUST retain validation on Linux, macOS, and Windows Git Bash.

## Governance

This constitution governs project design and delivery. A change that conflicts
with it MUST either be revised or include a constitution amendment in the same
change. Amendments MUST document the rationale, affected principles, compatibility
impact, and any required migration. Reviews MUST check the change against this
constitution and report any justified exception explicitly.

Versioning follows semantic versioning: MAJOR removes or redefines a governing
principle incompatibly; MINOR adds a principle or materially expands governance;
PATCH clarifies wording without changing obligations. The ratification date records
the original adoption date; the last-amended date changes whenever this document
changes.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): confirm original adoption date | **Last Amended**: 2026-10-03
