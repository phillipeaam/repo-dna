# Local release and CI analysis

RepoDNA analyzes delivery evidence that is available in a local clone. It does
not require a GitHub or GitLab token and does not contact remote APIs.

## Releases

Local Git tags are resolved to their target commits and reported with:

- semantic-version and prerelease classification;
- annotated or lightweight tag type;
- creation date, target commit, subject, and commit author;
- commits, changed files, additions, removals, and churn since the previous tag;
- average and median days between releases;
- commits and churn after the latest tag;
- version headings found in `CHANGELOG.md`, `CHANGES.md`, or `HISTORY.md`.

Rename and copy detection is enabled while calculating release ranges. The
analysis cannot prove that a corresponding GitHub/GitLab Release or binary
artifact was published. Shallow clones may also omit older tags and commits.

## Continuous integration

Static CI analysis recognizes GitHub Actions, GitLab CI, Jenkins, Azure
Pipelines, Bitbucket Pipelines, and CircleCI configuration already detected by
the generic inventory. Depending on the provider and available syntax, RepoDNA
extracts:

- workflow and provider names;
- triggers, stages, jobs, and step counts;
- test/quality and deployment/release job signals;
- matrices, schedules, manual triggers, cache and artifact usage;
- write permissions, `pull_request_target`, secret-reference counts, and GitHub
  actions that are not pinned to a full commit SHA.

These findings describe versioned configuration. They do not establish whether
a run succeeded, how long it took, which environment was deployed, whether an
approval occurred, or what remote branch-protection rules apply. Floating action
references and write permissions are review signals, not confirmed
vulnerabilities.

The results are available in the canonical JSON under
`generic_analysis.analysis.delivery`, in `report/delivery.html`, in the
onboarding dataset, and as provenance-backed Notion/LLM evidence.
