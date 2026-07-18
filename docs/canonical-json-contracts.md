# Canonical JSON contracts

RepoDNA validates its central data products before continuing report
generation:

| Artifact | Versioned contract |
|---|---|
| `report/data/report.json` | `report-1.2.0.schema.json` |
| `notion/evidence.json` | `notion-evidence-1.0.0.schema.json` |
| `portfolio/draft.json` | `portfolio-draft-1.0.0.schema.json` |

`report.json` is the sole public analysis source. Its `generic_analysis` section
is validated by `generic-analysis-1.1.0.schema.json`; that schema describes a
nested collector payload, not a second exported analysis document.

The `canonical_metrics` object defines the shared counts consumed by HTML,
Notion, portfolio, onboarding, LLM evidence, system documentation, and
snapshots. Derived artifacts may select or reformat evidence, but must not
recalculate these values.

Each document declares its contract through `$schema`. Schemas are packaged next
to their artifacts, so consumers do not need the RepoDNA source tree. A missing
required field, incompatible type, unknown top-level property, or incorrect
contract version stops generation before the archive is produced.

Patch-level schema filenames distinguish the contract definition from the
existing document `schema_version`. The canonical model is currently `1.2`.
