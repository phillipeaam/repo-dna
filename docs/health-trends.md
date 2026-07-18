# Health score trends

RepoDNA builds a health-score series from the current run and compatible
snapshots stored in `.repodna/snapshots/`. Create history by periodically running:

```bash
bash ./dna-analysis.sh --save-snapshot
```

The report contains:

- `health-trends/trends.json`: structured, validated trend data;
- `health-trends/health-trends-1.0.0.schema.json`: versioned contract;
- `health-trends/index.html`: navigable table and interpretation notes;
- `health-trends/health-score-trend.png`: optional matplotlib chart.

At least two compatible points are required for status `available`. Before that,
the current point is still exported with status `insufficient_history`.

## Compatibility rules

A point joins the main series only when repository name and type, privacy mode,
author filter, Git scope, snapshot schema major version, and health model version
match the current run. Excluded snapshots remain listed with their reasons.

The series reports score direction as `increased`, `decreased`, or `unchanged`.
That direction is descriptive: it does not independently prove improvement or
regression. Assessment coverage and the evidence behind each health dimension
must also be reviewed.
