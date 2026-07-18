# Composite hotspot model

RepoDNA ranks files for review with the versioned model
`repodna-composite-hotspot` version `1.0`.

## Formula

```text
score = commits * 2
      + churn / 50
      + current_lines / 100
      + authors * 3
      + 30 / (days_since_last_change + 30)
```

The score is rounded to two decimal places. `commits` counts unique commits that
touch the file, `churn` is additions plus removals, `current_lines` is the
current text line count, `authors` is the number of distinct historical authors,
and the final bounded term gives recently changed files a small contribution.

The model intentionally has no user-configurable weights. Changing any term or
weight requires a new model version.

## Interpretation

A higher score indicates relative review priority from combined activity, size,
collaboration, and recency evidence. It does not establish poor quality, defects,
complexity, formal ownership, or business importance. Components remain visible
next to the score so reviewers can interpret why a file ranked highly.

Every hotspot row and the enclosing Git dataset include the model and version.
Snapshots preserve this metadata. Period comparisons calculate hotspot score
deltas only when model name and version match; otherwise they retain the rest of
the comparison and explicitly mark hotspot scores as non-comparable.
