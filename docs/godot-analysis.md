# Godot analysis

RepoDNA activates this analyzer only when `project.godot` is present. It reads
the repository statically and does not need to open the Godot editor or import
the project.

## Evidence collected

- config version, project/version signal, main scene, display and physics;
- `.tscn` scenes, nodes, types, scripts, dependencies and signal connections;
- `.tres`, GDScript and Godot C# classes, functions, signals, exports, RPC,
  awaits, frame callbacks and resource loads;
- autoloads, input actions, rendering, localization, plugins and export presets;
- tests/frameworks, native extensions and assets;
- gameplay categories with confidence, paths, directories and Git activity;
- review signals for tree searches, node lookup, runtime loading around frame
  callbacks, manual signal connections, large scripts and many callbacks.

## Generated files

Godot projects receive `godot/index.html`, validated `godot/analysis.json`, its
versioned JSON Schema, and focused text evidence for every group above. The main
HTML, Notion, and LLM outputs reference the same canonical data.

## Interpretation limits

Gameplay categories require review. Performance findings are **signals**, not
confirmed bugs. Static files cannot prove runtime instantiation, executed signal
flows, export success, frame cost, formal ownership, or product impact. Binary
imported assets are counted but not semantically inspected.
