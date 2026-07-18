# Developer onboarding dataset

RepoDNA produces `onboarding/dataset.json` and a navigable
`onboarding/index.html` from repository evidence. The dataset contains:

- detected entrypoints;
- declared and suggested commands;
- primary documentation;
- modules, systems, graph summaries, and architectural boundaries;
- configuration, tests, CI/CD, Docker, and dependency manifests;
- quality-import status, contributors, aliases, and bus-factor summary;
- recommended reading candidates;
- questions that still require team knowledge.

Commands from package scripts, Python project scripts, and Make targets are
classified as `declared`. Conventional ecosystem commands are `suggested`, are
never executed by RepoDNA, and remain marked `confirmation_required`.

Strict privacy mode removes commands and entrypoints and uses the sanitized
repository landmarks from the canonical report. The JSON contract is versioned
as `onboarding-dataset-1.0.0` and validated on every run.
