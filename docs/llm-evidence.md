# LLM evidence package

RepoDNA writes `llm/evidence.json` as a compact, provenance-rich view of the
canonical `report/data/report.json`. It is designed for downstream language
models that need repository context without receiving the entire collector
payload or full source code.

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
