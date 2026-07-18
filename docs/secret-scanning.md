# Heuristic secret scanning

RepoDNA scans text files before archive creation and writes only masked findings
to `security/potential_secrets.txt`. Raw matched values never leave the scanner.
Each finding contains its type, severity, repository-relative file, line number,
and a preview retaining at most three leading and four trailing characters.

Severities are `Low`, `Medium`, `High`, and `Critical`. Private keys and AWS
credentials are critical; credentials and tokens are high; sensitive
configuration is generally medium; internal host signals are low. These are
review priorities, not proof of exposure.

Known placeholders such as `${TOKEN}`, `<your-password>`, `replace-me`, dummy,
sample, redacted, and repeated `x` values are ignored. Hashes and public IDs are
not findings unless they occur in a credential-specific assignment.

## Allowlist

Create `.repodna-secrets-allowlist` at the repository root. Each non-comment
line has three pipe-separated fields:

```text
path-pattern|line-or-*|finding-type-or-*
tests/fixtures/security.sh|*|*
config/example.env|12|possible API token
```

The allowlist stores no secret value. Path patterns use Bash glob syntax.
`.repodna-ignore` is also honored, including directory entries, exact files, and
glob patterns.

RepoDNA performs heuristic secret detection and is not a replacement for a
dedicated security scanner.
