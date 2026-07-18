# Period comparison

RepoDNA compares the current analysis with a versioned snapshot. Persist the
first baseline and run the analysis again later:

```bash
bash ./dna-analysis.sh --save-snapshot
bash ./dna-analysis.sh --save-snapshot
```

The second run automatically selects the most recent JSON snapshot under
`.repodna/snapshots/`. To choose a baseline explicitly:

```bash
bash ./dna-analysis.sh --compare-with .repodna/snapshots/2026-07-17_14-30-00_a1b2c3d4e5f6.json
```

Every run creates `comparison/comparison.json`, its versioned JSON Schema, and
`comparison/index.html`. With no available baseline, the artifact has status
`no_baseline` and explains that another snapshot is required.

## Compatibility

Comparisons record a warning and use status `scope_mismatch` when privacy mode,
author filter, Git scope, or health model differs. Different major snapshot
schema versions use status `incompatible_schema` and are not numerically
compared. This prevents unlike scopes from looking equivalent while preserving
an auditable artifact.

The comparison covers inventory, languages, architecture summaries, design
patterns, systems, quality signals, health, Git activity, and numeric risks.
Directions mean only `increased`, `decreased`, or `unchanged`: RepoDNA does not
infer quality improvement, regression, causality, or personal impact from a
delta alone.
