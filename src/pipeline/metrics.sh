collect_metrics() {
echo "[4/12] Calculating current project metrics..."

# Calculate specialized C# metrics only for C# project profiles.
if [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]]; then
# Count current C# files.
CURRENT_CS_FILES="$(count_current_files '*.cs')"

# Count current scenes.
CURRENT_SCENES="$(count_current_files '*.unity')"

# Count current prefabs.
CURRENT_PREFABS="$(count_current_files '*.prefab')"

# Count current animation clips.
CURRENT_ANIMATIONS="$(count_current_files '*.anim')"

# Count current animator controllers.
CURRENT_CONTROLLERS="$(count_current_files '*.controller')"

# Count current shader files.
CURRENT_SHADERS="$(count_current_files '*.shader')"

# Count current assembly definitions.
CURRENT_ASMDEFS="$(count_current_files '*.asmdef')"

# Count current UXML files.
CURRENT_UXML="$(count_current_files '*.uxml')"

# Count current USS files.
CURRENT_USS="$(count_current_files '*.uss')"

# Count current C# source lines.
CURRENT_CS_LINES="$(
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
C# files: $CURRENT_CS_FILES
C# source lines: $CURRENT_CS_LINES
Unity scenes: $CURRENT_SCENES
Unity prefabs: $CURRENT_PREFABS
Animation clips: $CURRENT_ANIMATIONS
Animator controllers: $CURRENT_CONTROLLERS
Shader files: $CURRENT_SHADERS
Assembly definitions: $CURRENT_ASMDEFS
UXML files: $CURRENT_UXML
USS files: $CURRENT_USS

These values describe the current repository state.
They may include third-party code, imported assets, examples, and generated files.
EOF
else
    CURRENT_CS_FILES=0
    CURRENT_SCENES=0
    CURRENT_PREFABS=0
    CURRENT_ANIMATIONS=0
    CURRENT_CONTROLLERS=0
    CURRENT_SHADERS=0
    CURRENT_ASMDEFS=0
    CURRENT_UXML=0
    CURRENT_USS=0
    CURRENT_CS_LINES=0
    cat > "$PROJECT_DIR/25_current_project_metrics.txt" <<EOF
Current Project Metrics
=======================

Project type: $PROJECT_TYPE
Code root: $CODE_ROOT

Stack-neutral metrics are available in report/data/generic-analysis.json and
the standardized HTML reports. No Unity or C# specialized collector was run.
EOF
fi

# Print the fifth progress step.
}
