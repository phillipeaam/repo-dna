#!/usr/bin/env bash

collect_specialized_git_metrics() {
    [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]] || return 0
    GIT_HISTORY[historical_cs_files]="$(count_historical_files '\.cs$')"

    [[ "$PROJECT_TYPE" == Unity ]] || return 0
    GIT_HISTORY[historical_unity_files]="$(count_historical_files '\.(cs|unity|prefab|asset|mat|anim|controller|overridecontroller|shader|hlsl|cginc|compute|shadergraph|asmdef|asmref|uxml|uss|playable|spriteatlas|rendertexture|physicmaterial|physicsmaterial2d)$')"
    GIT_HISTORY[historical_scenes]="$(count_historical_files '\.unity$')"
    GIT_HISTORY[historical_prefabs]="$(count_historical_files '\.prefab$')"
    GIT_HISTORY[historical_animations]="$(count_historical_files '\.(anim|controller|overridecontroller|playable)$')"
    GIT_HISTORY[historical_shaders]="$(count_historical_files '\.(shader|hlsl|cginc|compute|shadergraph)$')"
    GIT_HISTORY[historical_editor_cs]="$(analysis_git_log --name-only --pretty=format: 2>/dev/null | awk '{ line = tolower($0); if (line ~ /\.cs$/ && line ~ /(^|\/)editor(\/|$)/) print $0 }' | sort -u | awk 'NF { count++ } END { print count + 0 }')"
}
