#!/usr/bin/env bash

# Keep detection priority explicit because repositories can match multiple types.
declare -ar PROJECT_TYPES=(
    'Unity'
    'Flutter'
    'Unreal'
    'Godot'
    'Android'
    '.NET'
    'Node'
    'Python'
)

# Associate each project type with the function that recognizes it.
declare -Ar PROJECT_DETECTORS=(
    [Unity]='is_unity_project'
    [Flutter]='is_flutter_project'
    [Unreal]='is_unreal_project'
    [Godot]='is_godot_project'
    [Android]='is_android_project'
    [.NET]='is_dotnet_project'
    [Node]='is_node_project'
    [Python]='is_python_project'
)

# Associate each project type with its preferred source root.
declare -Ar PROJECT_ROOTS=(
    [Unity]='Assets'
    [Flutter]='lib'
    [Unreal]='Source'
    [Godot]='.'
    [Android]='app/src/main'
    [.NET]='.'
    [Node]='src'
    [Python]='src'
)

readonly GENERIC_PROJECT_TYPE='Generic Git repository'

is_unity_project() {
    [[ -f ProjectSettings/ProjectVersion.txt ]]
}

is_flutter_project() {
    [[ -f pubspec.yaml ]]
}

is_unreal_project() {
    local match
    match=$(find . -maxdepth 3 -type f -name '*.uproject' -print -quit 2>/dev/null)
    [[ -n "$match" ]]
}

is_godot_project() {
    [[ -f project.godot ]]
}

is_android_project() {
    local match

    match=$(find . -maxdepth 4 -type f \
        \( \
            -name AndroidManifest.xml \
            -o \
            \( \
                \( -name settings.gradle \
                   -o -name settings.gradle.kts \
                   -o -name build.gradle \
                   -o -name build.gradle.kts \) \
                -exec grep -Eq \
                    'com\.android\.(application|library|test|dynamic-feature|asset-pack)' \
                    {} \; \
            \) \
        \) \
        -print -quit 2>/dev/null)

    [[ -n "$match" ]]
}

is_dotnet_project() {
    local match

    match=$(find . -maxdepth 3 -type f \
        \( -name '*.sln' -o -name '*.csproj' \) \
        -print -quit 2>/dev/null)

    [[ -n "$match" ]]
}

is_node_project() {
    [[ -f package.json ]]
}

is_python_project() {
    [[ -f pyproject.toml ||
       -f requirements.txt ||
       -f setup.py ||
       -f setup.cfg ||
       -f Pipfile ]]
}

# Detect the first matching project type according to the configured priority.
detect_project_type() {
    local project_type
    local detector

    for project_type in "${PROJECT_TYPES[@]}"; do
        detector="${PROJECT_DETECTORS[$project_type]}"

        if "$detector"; then
            printf '%s' "$project_type"
            return
        fi
    done

    printf '%s' "$GENERIC_PROJECT_TYPE"
}

# Return the preferred root when it exists, otherwise use the repository root.
detect_code_root() {
    local project_type="${1:-}"
    local preferred_root="${PROJECT_ROOTS["$project_type"]:-.}"

    printf '%s' "$preferred_root"
}
