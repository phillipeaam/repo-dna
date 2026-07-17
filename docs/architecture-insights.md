# Entrypoints, coupling, cycles, and architectural boundaries

RepoDNA derives architectural signals from resolved source graphs. These signals
are evidence for review, not a declaration of the architecture intended by the
project authors.

## Entrypoints

Entrypoints combine language syntax and conventional files:

- Python main guards;
- C# `Main`, `Program.cs`, and ASP.NET host bootstrap;
- Java, Kotlin, Dart, Go, and Rust main functions;
- Rust `src/main.rs`;
- JavaScript package `main`, `module`, and `bin` declarations;
- Next.js route conventions.

Each result retains its path, language, kind, confidence, and concrete evidence.

## Coupling

- fan-in: number of modules depending on the module;
- fan-out: number of modules the module depends on;
- total coupling: fan-in plus fan-out;
- instability: `fan-out / (fan-in + fan-out)`;
- provider: incoming dependencies only;
- consumer: outgoing dependencies only;
- hub: both incoming and outgoing dependencies.

High coupling is a prioritization signal. It does not imply poor design.

## Boundaries

Directory tokens infer `presentation`, `application`, `domain`, and
`infrastructure` layers. RepoDNA then evaluates resolved module edges using an
inward dependency model derived from Clean Architecture:

- domain depends only on domain;
- application depends on application or domain;
- presentation depends on presentation, application, or domain;
- infrastructure depends on infrastructure, application, or domain.

Modules without a unique layer token remain unclassified and do not generate
violations. Findings therefore favor precision over forced classification.

## Cycles

Module cycles come from strongly connected components. A cycle crossing more
than one classified boundary receives high severity; a same-layer or
unclassified cycle receives medium severity.

Strict privacy mode preserves aggregate counts and removes entrypoint paths,
module identities, violation edges, and cycle members.
