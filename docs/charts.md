# Charts and visual evidence

RepoDNA generates PNG charts from the same Git CSV and structured generic JSON
used by the canonical report. Charts are renderings of collected evidence, not a
separate analysis source.

The chart set includes:

- commits by month;
- commits by year;
- churn by month for the analyzed technical-contribution window;
- composite hotspots by score;
- detected systems by current source-file count;
- commits by canonical author in the selected Git scope;
- system evolution by monthly commit touches;
- architecture-related change signals over time.

The architecture-evolution chart is a proxy. Its bars show the estimated
complexity delta in changed source files, while its line counts dependency,
configuration, and refactor-candidate signals. It does not reconstruct historical
architecture snapshots or prove that architecture improved or degraded.

System names and boundaries remain inferred. Hotspot scores combine change
frequency, churn, current size, authors, and recency. Churn measures activity and
is not a quality or productivity score.

When `--author` is supplied, Git-based charts reflect that selected author scope.
Strict privacy mode does not generate charts because labels and temporal patterns
can disclose repository or contributor information.

The canonical report registers only files that were successfully generated. The
HTML `charts.html` page therefore remains consistent when a chart lacks enough
data or matplotlib is unavailable.
