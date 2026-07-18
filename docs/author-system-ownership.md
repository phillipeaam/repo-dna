# Author and system activity ownership

RepoDNA estimates author-to-system relationships from Git history and detected
system boundaries. The result is an activity-based ownership proxy, not a claim
of legal authorship, formal responsibility, code review, or business impact.

For each author and system relationship, the report provides:

- commit touches: commits in which the author changed a file in the system;
- churn: added plus removed lines attributed by Git numstat;
- distinct files touched;
- share of system activity: the author's commit touches divided by all author
  commit touches in that system;
- author focus: the relationship's commit touches divided by that author's
  activity across detected systems;
- rank within the system;
- evidence confidence.

Confidence measures evidence volume. `high` requires at least ten commit touches,
three files, and a confidence score of at least 70. `medium` requires at least
three commit touches or two files and a score of at least 30. Other relationships
are `low` confidence. System-detection confidence is reported separately.

When `--author` is used, share of system activity is unavailable because other
contributors are intentionally outside the selected Git scope. Author focus is
still calculated within the selected author's detected-system activity.

Renames and copies use Git's `--find-renames` and `--find-copies` processing, but
historical ambiguity, squashed commits, shared accounts, generated code, and
missing history can still affect the result.

The repository-wide relationships also feed the separate
[bus factor by system](bus-factor.md) estimate.
