# Technical impact before and after contributions

RepoDNA treats each first-parent commit as a contribution and combines exact Git
diff metrics with before/after measurements of the source files changed by that
commit.

Exact diff evidence includes files touched, additions, deletions, churn, test
files, documentation files, configuration files, dependency manifests, and
affected top-level systems. Source blobs from the commit and its first parent
provide changed-scope line counts and estimated complexity before and after.

The complexity value is a language-neutral decision-token heuristic. It is useful
for comparison inside one contribution, but it is not equivalent to a dedicated
language complexity tool. Before/after source values cover changed source files,
not complete repository snapshots.

Generated technical signals include:

- `tests_changed`;
- `dependencies_changed`;
- `configuration_changed`;
- `documentation_changed`;
- `estimated_complexity_reduced` or `estimated_complexity_increased`;
- `refactor_candidate` when churn is high relative to the net line change.

These signals describe technical change only. They do not establish improvement,
quality, product impact, business impact, or developer performance. Merge history,
squashes, missing history, binaries, and generated files can affect interpretation.

RepoDNA analyzes up to the latest 200 matching commits on the first-parent chain.
With `--author`, the selected contributions are filtered using configured aliases
from `.repodna-authors`.
