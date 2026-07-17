# LLM evidence package

RepoDNA writes `llm/evidence.json` as a compact, provenance-rich view of the
canonical `report/data/report.json`. It is designed for downstream language
models that need repository context without receiving the entire collector
payload or full source code.

The contract follows semantic versioning. Version `1.0.0` is defined by
`schemas/llm-evidence-1.0.0.schema.json` and copied into each export as
`llm/schema.json`. The evidence document references that packaged schema through
`"$schema": "./schema.json"`.

Generation validates the complete document with JSON Schema Draft 2020-12 and
fails before archive creation when the contract is violated. This validation
requires the Python `jsonschema` package from `requirements-reporting.txt`.

Contract versions follow these compatibility rules:

- major: removes or changes existing fields, meanings, or allowed values;
- minor: adds optional fields or backward-compatible evidence categories;
- patch: clarifies descriptions or tightens validation without changing valid
  document semantics.

Consumers should reject unsupported major versions and may accept newer minor or
patch versions after validating against the schema packaged with the export.

The package contains:

- an explicit LLM usage contract;
- normalized evidence items with stable IDs;
- `fact`, `inference`, and `candidate` classifications;
- confidence, metrics, caveats, and confirmation requirements;
- source file and JSON Pointer provenance;
- architecture, systems, technologies, quality, security, Git, ownership,
  technical-impact, and career evidence;
- known unknowns and human-confirmation questions;
- truncation metadata for token control;
- a manifest pointing to the canonical, Notion, and portfolio artifacts.

The contract instructs consumers not to turn inferences or candidates into facts,
not to infer business impact or personal performance from Git activity, and to
preserve evidence pointers and caveats in generated claims.

Large detailed collections are bounded while aggregate counts remain available.
The canonical report remains the audit source whenever a downstream workflow
needs additional detail.

Strict privacy mode produces the LLM package from already-sanitized canonical
data. It therefore retains useful aggregate evidence without restoring commit
messages, author identities, paths, source snippets, secret values, or personal
achievement narratives removed by the collector.
