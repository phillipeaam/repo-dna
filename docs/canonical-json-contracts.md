# Canonical JSON contracts

RepoDNA validates its central data products before continuing report
generation:

| Artifact | Versioned contract |
|---|---|
| `report/data/report.json` | `report-1.3.0.schema.json` |
| `notion/evidence.json` | `notion-evidence-1.0.0.schema.json` |
| `portfolio/draft.json` | `portfolio-draft-1.0.0.schema.json` |

`report.json` is the sole public analysis source. Collector staging is validated
by `generic-analysis-1.2.0.schema.json`; the finalized `generic_analysis`
section is validated by `generic-analysis-core-1.0.0.schema.json`. Specialized
results are removed from that base and published under `specialized_analysis`
only when the corresponding analyzer is active.

The `canonical_metrics` object defines the shared counts consumed by HTML,
Notion, portfolio, onboarding, LLM evidence, system documentation, and
snapshots. Derived artifacts may select or reformat evidence, but must not
recalculate these values.

Each document declares its contract through `$schema`. Schemas are packaged next
to their artifacts, so consumers do not need the RepoDNA source tree. A missing
required field, incompatible type, unknown top-level property, or incorrect
contract version stops generation before the archive is produced.

Patch-level schema filenames distinguish the contract definition from the
existing document `schema_version`. The canonical model is currently `1.3`.
