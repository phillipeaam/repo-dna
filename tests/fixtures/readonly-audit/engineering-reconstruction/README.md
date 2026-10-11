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
| no-git-or-supporting-material | A selected snapshot has no accessible Git history, documentation, tests, runtime result, or metrics | Preserve those dimensions as `not_observed`/`unavailable`; do not infer that the work or outcome did not exist. |
| direct-source-fit | A source file at the stated baseline directly shows a structural behavior | Mark source nature and locator; it may support static behavior but not execution or benefit. |
| secondary-source-fit | A maintained technical summary describes a behavior but the underlying source is unavailable | Attribute the secondary account and limit the claim to what it supports. |
| personal-account-fit | A contributor describes a decision from memory with incomplete date and no corroboration | Label it `personal_account`; do not elevate it to independently verified fact. |
| unknown-source-metadata | A supplied note has no identifiable author or date | Record missing provenance fields as `unknown`; do not discard or score the source automatically. |
| stale-snapshot-source | A document describes an earlier version than the selected baseline | Record its snapshot/temporal scope and do not treat recency as universal authority. |
| shared-origin-sources | Two summaries repeat wording from the same original note | Record the origem compartilhada; repetition is not independent corroboration. |
| independent-corroboration | A source file and independently authored, scoped record support the same narrow claim | Record the separate origins and what each corroborates; calibrate confidence at claim level. |
| dimension-mismatch | A release note is offered as proof of individual authorship | Mark it unsuitable for authorship while retaining any release context it actually supports. |
| source-fit-vs-claim-confidence | A strong source supports one dimension but the claim also asserts an unsupported outcome | Separate source suitability by dimension from confidence in the broader claim; narrow or split the claim. |
| conclusion-vs-verification-need | A plausible explanation remains a hypothesis and separately needs human confirmation and runtime validation | Record the conclusion nature as `hypothesis` and the verification need as separate follow-up dimensions; runtime validation remains unexecuted. |

## Expected fields

Each reconstructed assertion has an `R-###` identifier, question/theme, repo/baseline/window, source location, evidence relation (`supports`, `limits`, `contradicts`, `context_only`), conclusion type, dimension supported, confidence rationale or no note, alternatives/counterevidence, limitations, and review state. A short optional `H-###` highlight links to its reconstruction/evidence; there may be zero to three.

The confidence rationale considers source type/direction, corroboration, contradiction, and scope. `high` requires direct scoped support without a material open contradiction; `medium` means partial/indirect/limited support without an equally supported alternative; `low` means weak/ambiguous support or equally plausible alternatives. Unsupported claims remain `unknown`/`unsupported` without a confidence rating.

## Safety and interpretation

Sources are local, user-supplied, or anonymous-public without authentication. No credentials, private-service access, target execution, test execution, build, hook, plugin, editor code, profiling, publication, or external write is used. Author/committer metadata, a system's existence, a configured test, or a plausible mechanism cannot prove a personal decision, collaboration, execution, result, or business benefit.
