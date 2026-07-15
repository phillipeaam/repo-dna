#!/usr/bin/env bash

# Define the supported project types.
readonly PROJECT_TYPE_UNITY='Unity'
readonly PROJECT_TYPE_ANDROID='Android'
readonly PROJECT_TYPE_FLUTTER='Flutter'
readonly PROJECT_TYPE_DOTNET='.NET'
readonly PROJECT_TYPE_UNREAL='Unreal'
readonly PROJECT_TYPE_GODOT='Godot'
readonly PROJECT_TYPE_NODE='Node'
readonly PROJECT_TYPE_PYTHON='Python'
readonly PROJECT_TYPE_GENERIC='Generic Git repository'

# Detect the primary project type from well-known repository markers.
detect_project_type() {
    if [[ -f ProjectSettings/ProjectVersion.txt ]]; then
        printf '%s' "$PROJECT_TYPE_UNITY"
    elif [[ -f pubspec.yaml ]]; then
        printf '%s' "$PROJECT_TYPE_FLUTTER"
    elif find . -maxdepth 3 -type f -name '*.uproject' -print -quit 2>/dev/null | grep -q .; then
        printf '%s' "$PROJECT_TYPE_UNREAL"
    elif [[ -f project.godot ]]; then
        printf '%s' "$PROJECT_TYPE_GODOT"
    elif [[ -f settings.gradle || -f settings.gradle.kts || -f build.gradle || -f build.gradle.kts ]] ||
         find . -maxdepth 4 -type f -name AndroidManifest.xml -print -quit 2>/dev/null | grep -q .; then
        printf '%s' "$PROJECT_TYPE_ANDROID"
    elif find . -maxdepth 3 -type f \( -name '*.sln' -o -name '*.csproj' \) -print -quit 2>/dev/null | grep -q .; then
        printf '%s' "$PROJECT_TYPE_DOTNET"
    elif [[ -f package.json ]]; then
        printf '%s' "$PROJECT_TYPE_NODE"
    elif [[ -f pyproject.toml || -f requirements.txt ]]; then
        printf '%s' "$PROJECT_TYPE_PYTHON"
    else
        printf '%s' "$PROJECT_TYPE_GENERIC"
    fi
}

# Pick a useful source root for the detected project type.
detect_code_root() {
    local project_type="$1"

    case "$project_type" in
        "$PROJECT_TYPE_UNITY")   [[ -d Assets ]] && printf 'Assets' || printf '.' ;;
        "$PROJECT_TYPE_FLUTTER") [[ -d lib ]] && printf 'lib' || printf '.' ;;
        "$PROJECT_TYPE_ANDROID") [[ -d app/src/main ]] && printf 'app/src/main' || printf '.' ;;
        "$PROJECT_TYPE_UNREAL")  [[ -d Source ]] && printf 'Source' || printf '.' ;;
        "$PROJECT_TYPE_NODE")    [[ -d src ]] && printf 'src' || printf '.' ;;
        "$PROJECT_TYPE_PYTHON")  [[ -d src ]] && printf 'src' || printf '.' ;;
        *)                         printf '.' ;;
    esac
}
