# RepoDNA

[![Quality, tests, and fixtures](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml/badge.svg)](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml)
[![License](https://img.shields.io/github/license/phillipeaam/repo-dna)](LICENSE)

![RepoDNA: static audits, traceable evidence and presentation](assets/images/banner.png)

RepoDNA is a set of Codex skills for investigating software repositories and presenting project findings clearly. The workflow is static: it examines available files and evidence without running the project under review.

## Skills

| Skill | Use it to | Result |
| --- | --- | --- |
| [`repodna-audit`](.agents/skills/repodna-audit/SKILL.md) | Investigate a repository's structure, history, implementation and claims. | One evidence-linked Markdown audit per product. |
| [`repodna-itch-format`](.agents/skills/repodna-itch-format/SKILL.md) | Prepare an existing audit for an itch.io project page. | Page copy; HTML and CSS when requested. Editorial decisions are recorded in the source audit. |

The audit distinguishes observed facts, inferences, personal accounts, conflicts and unknowns. The presentation skill uses the audit as its factual source. It does not redo the investigation or publish the page.

## Get started

Open this repository in Codex, place or identify a local copy of the project you want to examine, then invoke the relevant skill.

```text
Use $repodna-audit to audit target-repos/my-project.
```

By default, the audit is saved to `analysis-output/<slug>.md`. You can ask the presentation skill to prepare copy from that audit:

```text
Use $repodna-itch-format with the audit at analysis-output/my-project.md.
Prepare the page in English and provide separate HTML and CSS.
```

HTML/CSS are delivered only when requested. Drafts and decisions stay tied to the selected audit; no page is published automatically.

## Working with project data

Treat the project under review as untrusted, read-only input. RepoDNA never runs its code, scripts, builds, tests, hooks, plugins or editor tools. Audits and presentation drafts in `analysis-output/` and `private-context/` are Git-ignored. Ignore rules do not enforce file permissions: when the environment cannot verify write protection, the audit reports that limitation instead of claiming the project was protected.

## Develop and validate

The skills, runbooks and contracts describe the workflow. The [methodology](specs/001-readonly-audit-framework/methodology.md) and [coverage map](specs/001-readonly-audit-framework/source-inventory.md) explain its evidence standards. [CONTRIBUTING.md](CONTRIBUTING.md) covers changes to this repository.

Run the contract suite with Git, Bash and Python 3.11 or newer:

```bash
bash tests/run.sh --framework
python scripts/check-public-context.py
```

The tests use synthetic fixtures and validate RepoDNA's instructions. They do not inspect or execute a real target repository.

## License

RepoDNA is available under the [MIT License](LICENSE).
