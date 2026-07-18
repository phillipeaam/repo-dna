# Provider-neutral issues, pull requests, and releases

RepoDNA accepts a versioned, provider-neutral JSON export so GitHub, GitLab, or
another forge can feed the same analysis pipeline. The contract is defined by
`schemas/forge-data-1.0.0.schema.json`; `.repodna-forge.example.json` is a small
valid example.

## Usage

Pass an export explicitly:

```bash
bash ./dna-analysis.sh --forge-data path/to/forge-data.json
```

Or store it at `.repodna/forge-data.json` in the analyzed repository for
automatic discovery. The file should normally be excluded from Git when it
contains private project metadata.

The importer validates the complete document before analysis. Unknown fields,
missing required fields, invalid timestamps, and unsupported provider values
stop the run instead of being silently ignored.

## Common contract

The top level identifies the provider, repository, export timestamp, and export
scope. `scope.complete` must state whether pagination captured the complete
provider dataset. The three normalized collections are:

- `issues`: state, timestamps, author, assignees, labels, milestone, comment
  count, and confidentiality;
- `pull_requests`: also represents GitLab merge requests and carries merge
  timestamps, branches, participants, reviewers, commits, changed files,
  additions, deletions, and review comments;
- `releases`: tag, publication state, prerelease/draft signals, author, and
  asset count.

Identities use a stable provider ID plus optional username, display name, and
aliases. This lets `--author` recognize the same person across authored,
assigned, participating, and reviewing roles without exporting e-mail
addresses.

Issue and PR bodies, individual comments, review text, tokens, and provider API
responses are intentionally outside the contract. RepoDNA needs structured
evidence, not potentially sensitive conversation content.

## Analysis produced

The normalized import adds:

- issue state, close-time, comment, and label metrics;
- pull/merge request state, merge rate, time-to-merge, churn, review, and
  participation metrics;
- published, draft, prerelease, and asset counts;
- participant and reviewer counts;
- correlation between imported release tags and local Git tags;
- author-scoped roles when `--author` is supplied.

Results appear under `generic_analysis.analysis.forge_activity`, in
`report/forge-activity.html`, in Notion evidence, and in the LLM dataset.

Confidential issues always lose their title, URL, labels, and milestone before
reporting. Strict privacy mode removes all item rows, people, repository
identity, labels, URLs, branches, and tag names while retaining aggregate
metrics.

The import describes the supplied snapshot and is never presented as live
provider state. Future GitHub and GitLab adapters should only translate API
responses into this contract; report generation remains provider-independent.
