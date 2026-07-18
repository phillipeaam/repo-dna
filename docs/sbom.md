# SBOM and lockfile resolution

RepoDNA resolves installed dependency versions statically from repository
lockfiles and generates `sbom/bom.json` using CycloneDX 1.6 JSON. A navigable
inventory is available at `sbom/index.html`.

## Supported lockfiles

| Ecosystem | Files |
|---|---|
| npm | `package-lock.json`, `npm-shrinkwrap.json`, `yarn.lock`, `pnpm-lock.yaml` |
| Python | `poetry.lock`, `Pipfile.lock` |
| .NET | `packages.lock.json` |
| Flutter/Dart | `pubspec.lock` |
| Rust | `Cargo.lock` |
| Go | `go.sum` |
| Unity | `Packages/packages-lock.json` |
| PHP/Composer | `composer.lock` |
| Gradle/Maven coordinates | `gradle.lockfile` |

Each component records its package name, resolved version, ecosystem, Package
URL (PURL), direct/transitive signal, source lockfiles, and any dependency edges
available in the format. Directness is correlated with dependency manifests
when a lockfile does not encode it explicitly.

The same resolved inventory feeds vulnerability and license correlation. This
means scanner findings and imported license metadata can be matched against the
versions actually recorded by lockfiles instead of only manifest declarations.

## Boundaries

- RepoDNA does not execute package managers or access registries.
- A missing lockfile means transitive versions cannot be resolved exactly.
- Some textual lockfile formats omit full dependency edges or directness.
- The SBOM describes repository lockfiles, not deployed containers, binaries,
  dynamically loaded packages, or the runtime environment.
- Absence of a correlated vulnerability remains `not_resolved`; it never means
  vulnerability-free.

Strict privacy mode retains aggregate lockfile/component counts but removes
package identities, dependency edges, paths, and PURLs from the exported SBOM.
