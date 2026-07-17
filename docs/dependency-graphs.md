# Module and dependency graphs

RepoDNA resolves parsed imports against repository files before aggregating them
into directory modules. The canonical result is stored under
`generic_analysis.analysis.graphs`.

## Edge classifications

- `internal`: the import resolved to a source file in the repository;
- `external`: the import references a package, SDK, standard library, or namespace
  outside the repository;
- `unresolved`: a relative or explicitly project-local import could not be mapped
  to an existing source file.

External does not mean third-party ownership, and unresolved does not necessarily
mean broken code. Generated sources, compiler aliases, workspace mappings, build
variants, and dynamic loading can require configuration unavailable to static
analysis.

## Language resolution

- Python: dotted modules, relative levels, module files and `__init__.py`.
- JavaScript/TypeScript: relative paths, supported extensions and index modules.
- Java/Kotlin: qualified types resolved by package-like path and unique type file.
- C#: namespace-to-directory approximation for repository namespaces.
- Dart: relative imports, `dart:` SDK imports and own-package `package:` imports.
- Go: standard/external imports and project imports based on the `go.mod` module.
- Rust: `crate`, `self`, `super`, module files and `mod.rs`.

## Derived graphs

The file graph retains individual imports. The module graph aggregates internal
edges by source directory and reports fan-in, fan-out, reference counts and
strongly connected components. The dependency graph correlates external imports
with declarations found in dependency manifests.

Strict privacy mode retains summary counts but removes graph node names, paths,
edges, cycles, dependency identities, and unresolved import values.
