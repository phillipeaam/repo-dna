# Flutter analysis

RepoDNA activates the Flutter analyzer only when repository evidence confirms a
Flutter project: `pubspec.yaml` must contain the Flutter SDK structure. Project
names are never used to infer the stack.

The analyzer covers pubspec dependencies, widgets, screens/pages, routes, state
management, BLoC, Provider, Riverpod, GetX, MobX, Redux, localization, assets,
platform channels, Android/iOS native bridges, unit tests, integration tests,
Android product flavors, iOS schemes, and flavor-specific Dart entrypoints.

Generated output:

```text
flutter/
├── index.html
├── analysis.json
├── flutter-analysis-1.0.0.schema.json
├── dependencies.txt
├── widgets.txt
├── screens_routes.txt
├── state_management.txt
├── localization_assets.txt
├── platform_channels.txt
└── tests_flavors.txt
```

Declared dependencies and widgets are repository facts. Routes, architectural
consistency, native message-contract compatibility, and dynamically configured
flavors may require runtime or team confirmation. RepoDNA does not execute
Flutter, Gradle, Xcode, tests, or platform-channel calls during static analysis.

Strict privacy mode retains aggregate counts and detected approach names while
removing dependencies, widget/screen/route names, assets, channel identifiers,
native paths, test paths, and flavor details.
