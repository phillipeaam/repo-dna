# Git tags and releases

RepoDNA keeps local Git tags and provider releases as separate concepts.

- `generic_analysis.git.tags` contains up to 100 local tag names, sorted by Git
  creator date.
- `generic_analysis.git.recent_tags` contains the first 30 entries from that
  ordered local-tag inventory for compact consumers.
- `generic_analysis.analysis.delivery.releases` contains release-like ranges
  reconstructed from local tags, with explicit limitations.
- `generic_analysis.analysis.forge_activity.releases` contains releases from an
  optional provider-neutral GitHub/GitLab import.

The legacy `generic_analysis.git.releases` field was removed because it merely
copied tag names and incorrectly suggested that every local tag represented a
published release. Consumers should use `recent_tags` for compact tag inventory,
the delivery analyzer for local release-range evidence, or forge activity for
actual imported provider releases.

In strict privacy mode, `tags` and `recent_tags` are empty while their aggregate
count remains available.
