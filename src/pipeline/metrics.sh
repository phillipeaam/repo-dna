declare -gA CURRENT_METRICS=()

collect_metrics() {
log_info "Calculating current project metrics"

CURRENT_METRICS=(
    [csharp_files]=0 [csharp_lines]=0 [scenes]=0 [prefabs]=0
    [animations]=0 [controllers]=0 [shaders]=0 [asmdefs]=0 [uxml]=0 [uss]=0
)

# Calculate specialized C# metrics only for C# project profiles.
if [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]]; then
# Count current C# files.
CURRENT_METRICS[csharp_files]="$(count_current_files '*.cs')"

# Count current scenes.
CURRENT_METRICS[scenes]="$(count_current_files '*.unity')"

# Count current prefabs.
CURRENT_METRICS[prefabs]="$(count_current_files '*.prefab')"

# Count current animation clips.
CURRENT_METRICS[animations]="$(count_current_files '*.anim')"

# Count current animator controllers.
CURRENT_METRICS[controllers]="$(count_current_files '*.controller')"

# Count current shader files.
CURRENT_METRICS[shaders]="$(count_current_files '*.shader')"

# Count current assembly definitions.
CURRENT_METRICS[asmdefs]="$(count_current_files '*.asmdef')"

# Count current UXML files.
CURRENT_METRICS[uxml]="$(count_current_files '*.uxml')"

# Count current USS files.
CURRENT_METRICS[uss]="$(count_current_files '*.uss')"

# Count current C# source lines.
CURRENT_METRICS[csharp_lines]="$(
    analysis_find -type f -iname '*.cs' -print0 2>/dev/null |
        xargs -0 cat 2>/dev/null |
        wc -l |
        trim_count
)"

# Export the largest C# files.
analysis_find -type f -iname '*.cs' -exec wc -l {} \; 2>/dev/null |
    sort -rn |
    head -n 150 \
    > "$PROJECT_DIR/23_largest_csharp_files.txt"

# Export C# file counts by directory.
analysis_find -type f -iname '*.cs' -print 2>/dev/null |
    awk -F/ '
        {
            if (NF >= 3) {
                print $1 "/" $2 "/" $3
            } else if (NF >= 2) {
                print $1 "/" $2
            } else {
                print $1
            }
        }
    ' |
    sort |
    uniq -c |
    sort -nr \
    > "$PROJECT_DIR/24_csharp_files_by_directory.txt"

# Write current project metrics.
cat > "$PROJECT_DIR/25_current_project_metrics.txt" <<EOF
Current Project Metrics
=======================

Code root: $CODE_ROOT
C# files: ${CURRENT_METRICS[csharp_files]}
C# source lines: ${CURRENT_METRICS[csharp_lines]}
Unity scenes: ${CURRENT_METRICS[scenes]}
Unity prefabs: ${CURRENT_METRICS[prefabs]}
Animation clips: ${CURRENT_METRICS[animations]}
Animator controllers: ${CURRENT_METRICS[controllers]}
Shader files: ${CURRENT_METRICS[shaders]}
Assembly definitions: ${CURRENT_METRICS[asmdefs]}
UXML files: ${CURRENT_METRICS[uxml]}
USS files: ${CURRENT_METRICS[uss]}

These values describe the current repository state.
They may include third-party code, imported assets, examples, and generated files.
EOF
else
    cat > "$PROJECT_DIR/25_current_project_metrics.txt" <<EOF
Current Project Metrics
=======================

Project type: $PROJECT_TYPE
Code root: $CODE_ROOT

Stack-neutral metrics are available in report/data/report.json and
the standardized HTML reports. No Unity or C# specialized collector was run.
EOF
fi

# Print the fifth progress step.
}
