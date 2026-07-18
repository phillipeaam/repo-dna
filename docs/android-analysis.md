# Android analysis

Android repositories receive structured evidence under
`generic_analysis.analysis.android` and a dedicated `android/` report folder.
Other project types do not receive Android-specific output.

The analyzer correlates Gradle declarations, Android manifests, Java/Kotlin
symbols and imports, XML resources, and Git activity. It covers components,
screens, permissions, layouts, navigation, repositories, ViewModels, adapters,
SQLite, Room, Realm, Retrofit, OkHttp, JSON/XML, Google APIs, build types,
product flavors, variants, unit tests, and instrumented tests.

Generated reports:

```text
android/
├── index.html
├── analysis.json
├── android-analysis-1.0.0.schema.json
├── components.txt
├── dependencies.txt
├── permissions.txt
├── screens.txt
├── data_layer.txt
├── networking.txt
└── build_variants.txt
```

Manifest components are facts. Source components inferred from Java/Kotlin
names are marked as evidence requiring inheritance confirmation. Build variants
are statically approximated; RepoDNA does not execute Gradle. Library detection
does not prove active runtime use.

Strict privacy mode retains aggregate counts and technology booleans while
removing component names, permissions, paths, dependency coordinates, screens,
resources, and test paths.
