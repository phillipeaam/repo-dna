# Improved Unity analysis

Unity projects receive a dedicated structured analysis under
`generic_analysis.analysis.unity` and a conditional `report/unity-analysis.html`
page. Non-Unity repositories do not receive this page.

The collector reports enabled build scenes, render pipeline, input system,
platform signals, scripting backend, API compatibility, define symbols, quality
levels, graphics settings, package versions, Addressable groups, localization,
test assemblies, native plugins, and platform-specific code.

Gameplay categories correlate path tokens, AST symbols, imports, and Git
activity. Each category includes confidence, evidence score, files, primary
directories, matching commit touches, and frequently changed files. Categories
are inferred and require human confirmation.

Performance and risk findings are explicitly named **signals**. They cover
scene-wide lookup APIs, Resources loading, Instantiate/Destroy, loop proximity,
LINQ and GetComponent in frame methods, large frame methods, coroutine and event
lifecycle asymmetry, allocation-like APIs, large classes, missing asmdefs, and
approximate dependency cycles. Signals are not confirmed bugs and require code
review, profiling, runtime tests, and Unity-specific tooling.

Strict privacy mode preserves aggregate counts and categories while removing
paths, line numbers, scene names, Addressable group names, test assembly paths,
native plugin paths, platform-specific paths, and frequently changed files.
