# RepoDNA

[![Quality, tests, and fixtures](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml/badge.svg)](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml)
[![License](https://img.shields.io/github/license/phillipeaam/repo-dna)](LICENSE)

![RepoDNA: static audits, traceable evidence and presentation](assets/images/banner.png)

RepoDNA is a Codex-guided framework for static, evidence-led repository audits. Its two product skills live under `.agents/skills/`: `repodna-audit` investigates a selected repository, and `repodna-itch-format` prepares itch.io copy from an existing audit. The methodology, tests and specifications support those skills; there is no separate analyzer CLI or runtime.

Each audited product has exactly one factual Markdown report, defaulting to `analysis-output/<safe-product-slug>.md`. A user-selected existing external audit can remain the sole authority. The document combines the current project record, evidence, coverage, claims, questions and audit history. The framework does not create alternate HTML or JSON/CSV reports, archives or Notion exports. Explicitly requested HTML/CSS application derivatives remain private and reference the sole report.

## Start an audit

1. Open this checkout in Codex.
2. Put a local repository copy under `target-repos/` and select it explicitly. Relate multiple repositories only when they are confirmed parts of the same product.
3. Invoke the `repodna-audit` skill.
4. The skill checks the host profile and target/Git paths. If write prevention is unverified, it warns you and proceeds with static inspection; the report marks preservation as unverified/observed, never guaranteed.
5. Read the single Markdown result in `analysis-output/`.

`target-repos/` and `analysis-output/` are Git-ignored for privacy. Ignore rules do not enforce filesystem permissions. The agent must not intentionally write to or execute the target, but a writable session can still permit incidental changes. Use a protected copy when available; otherwise review the preservation limitation in the final Markdown.

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

## Prepare a project presentation

Use the [repodna-itch-format skill](.agents/skills/repodna-itch-format/SKILL.md) to prepare itch.io copy from a selected audit. The audit skill owns factual investigation; the presentation skill consumes its report.
The [presentation runbook](.agents/skills/repodna-audit/references/presentation-format.md)
selects claims for an audience, purpose, language and channel, keeping drafts,
evidence routes, omissions and review history in the same product Markdown.
Update the selected existing audit in place with authorized access, preserving
source, IDs, baseline and limitations. Do not create a second working report.

The optional `presentation_version: 1.0` extension retains factual schema 2.1.0.
The MVP includes [itch.io guidance](.agents/skills/repodna-itch-format/references/channel-itch.md)
and a fictional plain-text channel for controlled validation. Other real stores
require their own documented capabilities before compatibility can be claimed.
Descriptions, metadata, media and native actions are considered separately.
Clarity and accurate crediting guide the writing; author-provided tone, humor,
vocabulary and atmosphere remain project choices, with provisional suggestions
when no brief exists. There is no fixed visual template or required narrative.

Draft/acceptance, freshness, factual confidence, media permissions and observed
public state remain independent. A material change invalidates affected approval;
acceptance requires an explicit human decision. Requested application files go
under ignored `private-context/presentation-applications/<slug>/`; versions and
configuration are recorded in the audit. The method does not publish, generate
alternate reports, create previews or execute the target. The
[synthetic scenarios](tests/fixtures/readonly-audit/presentation-model/README.md)
verify the framework contract, not a real product's behavior or audience response.

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

Acceptance scripts use only synthetic framework fixtures; they must never inspect or execute a selected target. The CI runs these contracts on Linux, macOS and Windows. This validates portability of the fixture tests, not the Codex host's effective filesystem permissions.

```bash
bash tests/run.sh --framework
```

Codex host profiles may remain `unverified` in the [host matrix](tests/fixtures/readonly-audit/README.md); that status now warns and limits preservation claims instead of blocking static audits.

## License

See [LICENSE](LICENSE).

## Reuse the presentation model

Follow [the neutral model](.agents/skills/repodna-audit/references/presentation-template.md): existing audit → editorial selection → channel text → optional visual application → recorded validated version. Select supported blocks and project-specific voice/visuals; missing information is omitted or qualified. Preserve previous drafts as history. User-validated page checks need not be repeated. Subjective scores are not audit results or approval criteria. Private real examples stay in their sole reports and application files, never shared fixtures.


### Call the presentation skill

```text
Use $repodna-itch-format com o audit E:/caminho/relatorio.md.
Prepare em inglês e entregue HTML e CSS separados.
```

```text
Use $repodna-itch-format com o audit que acabamos de gerar.
Prepare o texto para a página do jogo no itch.io.
```

Explicit paths take precedence; an unambiguous conversational audit needs no repeated path. Ambiguity requires only source identification. The neutral model guides the agent internally. An audit may suggest this next command but does not run presentation automatically. No real-project rewriting, publishing or runtime testing occurs when creating the skill.
