# RepoDNA

[![Quality, tests, and fixtures](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml/badge.svg)](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml)
[![License](https://img.shields.io/github/license/phillipeaam/repo-dna)](LICENSE)

RepoDNA is a Codex-guided framework for static, evidence-led repository audits. Its primary entry point is the `repodna-audit` skill under `.agents/skills/repodna-audit/`.

Each audited product has exactly one persistent user-facing result: `analysis-output/<safe-product-slug>.md`. The document combines the current project record, evidence, coverage, claims, questions and audit history. The framework does not create HTML, JSON/CSV reports, archives, Notion exports or attachments.

## Start an audit

1. Open this checkout in Codex.
2. Put a local repository copy under `target-repos/` and select it explicitly. Relate multiple repositories only when they are confirmed parts of the same product.
3. Invoke the `repodna-audit` skill.
4. The skill checks the effective host permissions before substantive inspection. It proceeds only when the selected host profile is recorded as supported in [the readonly fixture matrix](tests/fixtures/readonly-audit/README.md), the target and its real Git storage are protected from writes, and `analysis-output/` remains writable separately.
5. Read the single Markdown result in `analysis-output/`.

`target-repos/` and `analysis-output/` are Git-ignored for privacy. Ignore rules do not enforce filesystem permissions. If the host cannot prove the readonly boundary, the audit blocks; do not use a target inside a writable scope and assume a prompt or final status check protects it.

## Audit method

The approved method is entirely local: the constitution and feature specification
govern requirements, while the skill, runbooks and contracts govern execution.
Use the [incorporated methodology](specs/001-readonly-audit-framework/methodology.md)
and [local coverage map](specs/001-readonly-audit-framework/source-inventory.md)
for detailed rules. No access to original research pages, Notion account or
connector is required. Optional external evidence about a selected target does
not change the local method automatically.

The workflow includes preparation, A1 forensic analysis, B1 production and architecture, B2 static runtime review, B3 release provenance, B4 publication readiness, source reconciliation, Markdown consolidation and final preservation checks. It records facts, inferences, personal accounts, conflicts and unknowns separately. It never executes target code, scripts, builds, tests, hooks, plugins, editor code or profiling. Dynamic validation belongs to a separate external process and is not started or orchestrated by this framework.

Start with [the skill entry point](.agents/skills/repodna-audit/SKILL.md) and [the workflow](.agents/skills/repodna-audit/references/workflow.md). The design and acceptance scenarios live in [the feature specification](specs/001-readonly-audit-framework/spec.md), [quickstart](specs/001-readonly-audit-framework/quickstart.md) and [fixture guide](tests/fixtures/readonly-audit/README.md).

## Migration status

The former `repodna analyze` CLI, installer and multi-format report flow are retired. Their old entry points now stop with a migration message and do not inspect repositories. Historical collectors and renderers remain in the repository for reference, but are not part of the supported audit path; reuse requires an explicit readonly review and separation from the legacy output pipeline.

## Validate framework contracts

Original research provenance can be kept under `private-context/`, which is
ignored, optional and excluded from distribution. It is research input, not an
audit deliverable. Versioned documentation uses generalized rules and fictional
examples, without private project names or personal page metadata.

With Python 3.11+ and Git available, run `python scripts/check-public-context.py`
before sharing. It checks current files and staged content for known metadata;
an old staged copy still blocks after its working file is sanitized. Optional
terms in `private-context/known-sensitive-terms.txt` help identify known private
names. Patterns cannot identify all confidential information: review the content
manually too, including binary files. Current cleanup does not remove information
from existing Git history.
The release packager also checks the exact tag tree with `--ref` before creating
an archive, so a clean checkout does not bypass metadata checks on an older tag.

Acceptance scripts use only synthetic framework fixtures; they must never inspect or execute a selected target. The CI runs these contracts on Linux, macOS and Windows. This validates portability of the fixture tests, not the Codex host's effective filesystem permissions.

```bash
bash tests/run.sh --framework
```

All Codex host profiles remain `unverified` in the [host matrix](tests/fixtures/readonly-audit/README.md), so a real audit currently blocks until a profile's readonly guarantees are validated and recorded. Legacy report-generation tests are excluded from the supported runner.

## License

See [LICENSE](LICENSE).
