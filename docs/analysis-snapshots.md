# Versioned analysis snapshots

Every RepoDNA run generates a compact point-in-time snapshot under the exported
`snapshots/` directory. Use `--save-snapshot` to also persist the validated
snapshot in the analyzed repository:

```bash
bash ./dna-analysis.sh --save-snapshot
```

Persistent snapshots use this layout:

```text
.repodna/
└── snapshots/
    ├── analysis-snapshot-1.0.0.schema.json
    └── 2026-07-17_14-30-00_a1b2c3d4e5f6.json
```

The `.repodna/` directory is excluded from repository analysis, so previous
snapshots do not inflate file counts or language metrics. It is intentionally not
added to `.gitignore`; teams may review and commit selected snapshots to establish
a versioned analysis history.

## Snapshot contract

Snapshot contract `1.0.0` uses JSON Schema Draft 2020-12 and is defined by
`schemas/analysis-snapshot-1.0.0.schema.json`. Generation fails if the snapshot
does not validate.

Each snapshot records:

- generation time, Git commit, and branch;
- privacy and author scope;
- repository inventory and languages;
- architecture, framework, graph, and design-pattern summaries;
- detected systems with stable comparison metrics;
- coverage, tests, lint, vulnerability, and dependency summaries;
- health score, grade, dimensions, and model version;
- contributor count, churn, hotspots, technical-impact summary, and ownership
  summary;
- risks and provenance versions.

Snapshots deliberately omit source code, commit messages, full contribution
history, diagnostic text, secret values, and full dependency findings. Detailed
evidence remains in the canonical report for that run.

Snapshots generated with different privacy scopes, author filters, health-model
versions, or major snapshot schemas should not be compared without explicitly
accounting for those differences. Period comparison and health trends will consume
this contract in subsequent RepoDNA features.
