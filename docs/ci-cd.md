# CI/CD

RepoDNA runs four independent CI gates for every push and pull request:

- **Bash quality:** ShellCheck, incremental `shfmt`, and fast Bats tests;
- **full suite:** all standalone Bash integration tests on Ubuntu;
- **fixtures:** project detection and portable edge cases on Linux, macOS, and
  Windows Git Bash;
- **artifact contract:** a real report export, JSON parsing, HTML entrypoint
  verification, and archive-content verification.

Concurrent runs for the same branch are cancelled so obsolete commits do not
consume runner time. Jobs use read-only repository permissions.

## Releases

Pushing a semantic-version tag such as `v1.2.3` starts the release workflow. A
manual dispatch may target an existing tag. Before publishing, the workflow:

1. verifies that the tag exists and follows semantic versioning;
2. requires a matching `## [1.2.3]` section in `CHANGELOG.md`;
3. creates ZIP and TAR.GZ source distributions with a versioned root directory;
4. creates `SHA256SUMS` and uploads the files as workflow artifacts;
5. publishes the same files and changelog section in a GitHub Release.

Prepare a release by moving relevant entries from `Unreleased` into a versioned
section, committing that change, and tagging that exact commit:

```bash
git tag -a v1.2.3 -m "RepoDNA v1.2.3"
git push origin v1.2.3
```

The release job is the only workflow with `contents: write`; CI remains
read-only.
