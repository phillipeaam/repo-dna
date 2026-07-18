# Unreal analysis

RepoDNA activates this analyzer only when an `.uproject` file is present. It
analyzes versioned repository evidence without requiring Unreal Editor.

## Evidence collected

- `.uproject` and `.uplugin` descriptors, EngineAssociation, modules, enabled
  plugins, loading phases, target platforms and allowlists;
- `.Build.cs` public/private/dynamic dependencies and `.Target.cs` target type;
- C++ classes, inheritance, `UCLASS`, `USTRUCT`, `UENUM`, `UFUNCTION`,
  `UPROPERTY`, delegates, RPC/replication signals, Tick and Git activity;
- Config sections and key names, input declarations, Content assets, maps,
  automation tests and native plugin source;
- gameplay categories with confidence, evidence paths, primary directories and
  available Git activity;
- review signals for Tick, actor iteration, synchronous asset loading, dynamic
  object/component lookup and large source files.

## Generated files

Unreal projects receive `unreal/index.html`, validated `unreal/analysis.json`,
its versioned JSON Schema, and focused reports for project/modules/targets,
source/reflection, plugins, Content/maps, configuration/input, tests, gameplay
systems and review signals. Main HTML, Notion and LLM outputs use the same data.

## Interpretation limits

`.uasset` and `.umap` are binary and are inventoried by path and naming prefix;
Blueprint graphs and map internals require Unreal tooling. Performance findings
are **signals**, not confirmed bugs. Static evidence cannot prove packaging,
runtime behavior, formal ownership, or product impact.
