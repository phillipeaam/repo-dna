# Structured documentation by system

RepoDNA generates one evidence-based document for each detected system under
`system-docs/`:

```text
system-docs/
├── index.html
├── systems.json
├── system-documentation-1.0.0.schema.json
├── systems/
│   └── <system>.html
└── data/
    └── <system>.json
```

Each document contains repository metrics, languages, dependency manifests,
symbols, entrypoints, coupling evidence, Git evolution, activity ownership, bus
factor, confirmed facts, explicit inferences, limitations, and unknowns requiring
human confirmation.

RepoDNA does not infer product purpose, public contracts, operational behavior,
formal ownership, or business impact when repository evidence cannot establish
them. Those gaps remain visible as questions instead of becoming unsupported
narrative.

The catalog and individual JSON files implement the versioned
`system-documentation-1.0.0` contract. Strict privacy mode uses the already
sanitized paths, symbols, systems, and contributor identities from the canonical
report.
