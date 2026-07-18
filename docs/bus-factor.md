# Bus factor by system

RepoDNA estimates how concentrated historical activity is inside each detected
system. The estimated bus factor is the minimum number of authors whose
cumulative author-file commit-touch share reaches 75% of that system's activity.

| Estimated factor | Classification |
|---:|---|
| 1 | High concentration |
| 2 | Moderate concentration |
| 3 or more | Distributed activity |

The report includes active-author count, total commit touches, covered activity,
critical authors, evidence confidence, and system-detection confidence.

The calculation is unavailable with `--author`, because a filtered run excludes
the other contributors required to measure concentration.

This metric is an activity-concentration proxy. It does not measure exclusive
knowledge, replaceability, formal responsibility, review work, mentoring, pair
programming, or team performance. Squashed history, aliases, repository moves,
and inferred system boundaries can change the estimate.
