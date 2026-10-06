# Synthetic fixtures: engineering reconstruction

All examples below are fictional and contain no real person, employer, project, private URL, or source code. They define evidence situations for acceptance checks; the audit method reads only these framework fixtures and never executes a selected target.

| Case | Synthetic observations | Expected boundary |
|---|---|---|
| convergent-local-evidence | A local diff and a supplied design note describe the same state transition at baseline `fixture-a@a1` | State the observed mechanism as a scoped fact; a source must support the specific claim. |
| conflicting-sources | A changelog and a supplied note give different dates for a decision | Keep both claims, scope each source, mark conflict, and avoid choosing by recency alone. |
| group-commit | One shared author field records a commit that changes a subsystem | Report registered metadata and shared contribution only; do not infer individual decision or total ownership. |
| configured-test-no-result | A test file and CI configuration exist, but no execution result is present | Record a configured validation path, not a test run, pass, quality claim, or outcome. |
| scoped-runtime-log | A materialized log identifies baseline, scenario, operating environment, and one measured event | Limit the result to that snapshot, scenario, and environment; do not generalize to product impact. |
| inaccessible-private-review | A note refers to a review in a private service that is not provided or locally materialized | Mark the source unavailable/not observed; do not claim the review was consulted or absent. |
| limited-memory | A user account recalls a constraint but cannot identify the date or exact decision | Attribute the account; leave unsupported details unknown and ask only if the answer would change the claim materially. |
| plausible-benefit-unmeasured | Static code suggests a shorter path, but there is no user or performance measurement | Describe the structural change; keep benefit and causal impact hypothetical/unknown. |
| alternative-explanations | Two implementation paths plausibly explain the same observable behavior | Record both alternatives and any counterevidence; confidence is not high while a material alternative remains open. |
| narrative-order-varies | Two supported summaries arrange context, mechanism, contribution, and trade-off in different orders | Accept both when material claims remain traceable; no fixed headings or sequence are required. |
| no-supported-highlight | The available evidence supports facts but no concise narrative highlight | Zero highlights is valid; do not fill gaps for symmetry. |
| confidence-calibration | One direct scoped record, one partial source, one ambiguous source, and one unsupported claim | Apply high/medium/low with rationale to supported claims; unsupported remains unknown with no confidence note. |
| editorial-review-state | A suggested paragraph is corrected after human review | Preserve draft and correction provenance; review state never changes evidence type or strength. |

## Expected fields

Each reconstructed assertion has an `R-###` identifier, question/theme, repo/baseline/window, source location, evidence relation (`supports`, `limits`, `contradicts`, `context_only`), conclusion type, dimension supported, confidence rationale or no note, alternatives/counterevidence, limitations, and review state. A short optional `H-###` highlight links to its reconstruction/evidence; there may be zero to three.

The confidence rationale considers source type/direction, corroboration, contradiction, and scope. `high` requires direct scoped support without a material open contradiction; `medium` means partial/indirect/limited support without an equally supported alternative; `low` means weak/ambiguous support or equally plausible alternatives. Unsupported claims remain `unknown`/`unsupported` without a confidence rating.

## Safety and interpretation

Sources are local, user-supplied, or anonymous-public without authentication. No credentials, private-service access, target execution, test execution, build, hook, plugin, editor code, profiling, publication, or external write is used. Author/committer metadata, a system's existence, a configured test, or a plausible mechanism cannot prove a personal decision, collaboration, execution, result, or business benefit.
