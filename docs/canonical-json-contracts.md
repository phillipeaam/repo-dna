# Canonical JSON contracts

RepoDNA validates its four central data products before continuing report
generation:

| Artifact | Versioned contract |
|---|---|
| `report/data/report.json` | `report-1.1.0.schema.json` |
| `report/data/generic-analysis.json` | `generic-analysis-1.1.0.schema.json` |
| `notion/evidence.json` | `notion-evidence-1.0.0.schema.json` |
| `portfolio/draft.json` | `portfolio-draft-1.0.0.schema.json` |

Each document declares its contract through `$schema`. Schemas are packaged next
to their artifacts, so consumers do not need the RepoDNA source tree. A missing
required field, incompatible type, unknown top-level property, or incorrect
contract version stops generation before the archive is produced.

Patch-level schema filenames distinguish the contract definition from the
existing document `schema_version`, preserving compatibility with consumers of
the current `1.1` and `1.0` formats.
