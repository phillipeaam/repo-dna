# Heuristic system detection

RepoDNA distinguishes structural entities from architectural system candidates.
Directories and modules are repository structure; they are not automatically
reported as systems.

`generic_analysis.analysis.structural_entities` classifies observed entities as
`directory`, `module`, `package`, `namespace`, `infrastructure_component`,
`test_suite`, or `documentation`.

`generic_analysis.analysis.systems` contains cross-file capability candidates.
The classifier combines exact path terms, parsed symbols, imports, detected
entrypoints, graph proximity, and Git hotspot activity. Each candidate includes:

- `entity_type: system`;
- numeric `confidence` from `0.0` to `1.0`;
- a human-readable `confidence_level`;
- representative `files`;
- scored `evidence` with the signals found in each file;
- `evidence_categories` describing the independent signal families.

Candidates below `0.60` are omitted. Every returned system still has
`confirmation_required: true`: naming and cohesion are heuristic and do not
prove the intended product boundary, ownership, or business responsibility.
