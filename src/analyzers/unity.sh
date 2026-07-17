#!/usr/bin/env bash

collect_unity_assets() {
    [[ "$PROJECT_TYPE" == Unity ]] || return 0
    analysis_find -type f -iname '*.unity' -print 2>/dev/null | sort > "$PROJECT_DIR/03_scenes.txt"
    analysis_find -type f -iname '*.prefab' -print 2>/dev/null | sort > "$PROJECT_DIR/04_prefabs.txt"
    analysis_find -type f \( -iname '*.anim' -o -iname '*.controller' -o -iname '*.overrideController' \) -print 2>/dev/null |
        sort > "$PROJECT_DIR/05_animation_assets.txt"
    analysis_find -type f \( -iname '*.shader' -o -iname '*.hlsl' -o -iname '*.cginc' -o -iname '*.compute' -o -iname '*.shadergraph' \) -print 2>/dev/null |
        sort > "$PROJECT_DIR/06_shader_assets.txt"
    analysis_find -type f \( -iname '*.asmdef' -o -iname '*.asmref' \) -print 2>/dev/null |
        sort > "$PROJECT_DIR/07_assembly_definitions.txt"
    analysis_find -type f \( -iname '*.uxml' -o -iname '*.uss' \) -print 2>/dev/null |
        sort > "$PROJECT_DIR/08_ui_toolkit_assets.txt"
    analysis_find -type f -iname '*.playable' -print 2>/dev/null | sort > "$PROJECT_DIR/09_timeline_assets.txt"
    analysis_find -type f -path '*/Resources/*' -print 2>/dev/null | sort > "$PROJECT_DIR/10_resources_assets.txt"
    analysis_find -type f \( -path '*Addressable*' -o -iname '*Addressable*' \) -print 2>/dev/null |
        sort > "$PROJECT_DIR/11_addressables_assets.txt"
}
