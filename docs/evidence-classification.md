# Evidence classification

RepoDNA separates conclusions into three forms in
`generic_analysis.analysis.conclusions`.

- `fact`: a directly observed repository value, with confidence `1.0` and one
  or more file paths or JSON pointers as evidence.
- `inference`: an interpretation produced by a documented heuristic. It carries
  numeric confidence from `0.0` to `1.0` and concrete supporting evidence.
- observation status: the result of looking for external evidence. `imported`
  means a compatible artifact was parsed, `invalid` means one was found but
  could not be parsed, and `not_observed` means none was discovered.

`not_observed` is deliberately different from a numeric zero. For example, no
coverage artifact produces a message saying that coverage was not observed and
keeps `line_coverage_percent` as `null`. It never becomes `0%`.

The health model only includes imported external measurements in its assessed
denominator. Missing coverage, test-result, linter, or scanner artifacts reduce
assessment coverage instead of reducing the repository score.
