# Personal achievement candidates

RepoDNA generates personal achievement candidates only when `--author` selects a
canonical contributor identity. Author aliases from `.repodna-authors` are
included in that scope.

Candidates combine author-filtered technical impact and author-to-system activity
evidence. They can identify contribution scope, system concentration, test-related
changes, dependency changes, and estimated complexity reductions.

Every candidate contains a neutral evidence-backed draft, factual basis,
repository metrics, evidence pointers, confidence, incomplete X-Y-Z inputs, and
explicit questions requiring personal confirmation.

Candidates are not achievements and are never presented as approved claims by
default. Git history cannot prove formal responsibility, intent, difficulty,
product outcome, business impact, or whether a metric represents an improvement.
The user must supply this context and explicitly approve a claim through the
portfolio confirmation workflow.

Without `--author`, the status is `requires_author_filter` and no personal
candidates are generated. Strict privacy mode removes candidate narratives and
personal identifiers while preserving aggregate candidate counts.
