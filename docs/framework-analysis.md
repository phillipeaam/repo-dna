# Framework analysis methodology

RepoDNA framework adapters consume structured repository evidence after language
parsing. They do not execute applications, resolve dependency graphs, or assume
that a declared framework is correctly configured.

## Evidence model

| Evidence | Typical weight | Meaning |
|---|---:|---|
| Declared dependency | 5–6 | Strong manifest-level evidence. |
| Framework import or namespace | 4 | Source code directly references the framework. |
| Canonical project path or manifest | 1–5 | The repository follows a recognized framework convention. |
| Parsed symbol role | 2 | A syntax-tree symbol matches a framework concept. |
| Parsed call | 1–2 | Source code calls a characteristic framework API. |

An adapter is reported at four points. Findings are `high` confidence at eight
points, or at six points when at least two evidence categories agree. Other
reported findings are `medium` confidence. Repeated matches within one marker do
not increase its score, preventing large generated directories from inflating
confidence.

The score compares evidence inside one adapter; it is not a quality score and
must not be compared between unrelated frameworks.

## Supported adapters

- Unity: runtime/editor namespaces, Unity paths, component types and API calls.
- ASP.NET Core: packages, namespaces, controllers, endpoints and middleware paths.
- Spring: dependencies, namespaces, stereotype roles and layered paths.
- Android: dependencies, namespaces, manifest/resources, components and UI APIs.
- Flutter: SDK dependency, imports, widgets, runtime/navigation and UI paths.
- React: dependencies, modules, hooks/runtime and component paths.
- Next.js: dependency, modules, routing conventions and data lifecycle symbols.

Every result retains individual evidence rows and supporting paths in standard
privacy mode. Strict privacy mode preserves the aggregate classification but
removes those values and paths.
