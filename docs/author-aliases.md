# Author alias configuration

`.repodna-authors` groups multiple Git names and e-mail addresses under one
canonical contributor identity. RepoDNA validates the complete file before
calculating contributors, system activity ownership, bus factor, technical
impact, or achievement candidates.

```yaml
Phillipe Augusto:
  names:
    - Phillipe Augusto de Araújo Mendonça
    - phillipe
  emails:
    - phillipe@example.com
    - phillipe@company.example
```

## Grammar

- A non-indented `Name:` starts one canonical identity.
- Only the indented sections `names:` and `emails:` are supported.
- Aliases are list items beginning with `-` and cannot be empty.
- E-mail aliases must contain a local part, `@`, and a domain part.
- Blank lines and full-line comments beginning with `#` are allowed.
- Identity and alias comparisons are case-insensitive.

Canonical names, sections and aliases cannot be repeated. A name or e-mail alias
cannot belong to more than one canonical identity. Sections that are declared
must contain at least one value.

Invalid input stops collection and reports the filename, line number and reason,
for example:

```text
Error: .repodna-authors:6: duplicate email alias 'PERSON@example.com'; already assigned to 'First Person' on line 3
```

This strict failure is intentional: silently selecting one identity would make
all downstream author-based evidence unreliable.
