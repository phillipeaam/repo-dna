#!/usr/bin/env bash

# Detect the primary project type from well-known repository markers.
detect_project_type() {
    if [[ -f ProjectSettings/ProjectVersion.txt ]]; then
        printf 'Unity'
    elif [[ -f pubspec.yaml ]]; then
        printf 'Flutter'
    elif find . -maxdepth 3 -type f -name '*.uproject' -print -quit 2>/dev/null | grep -q .; then
        printf 'Unreal'
    elif [[ -f project.godot ]]; then
        printf 'Godot'
    elif [[ -f settings.gradle || -f settings.gradle.kts || -f build.gradle || -f build.gradle.kts ]] ||
         find . -maxdepth 4 -type f -name AndroidManifest.xml -print -quit 2>/dev/null | grep -q .; then
        printf 'Android'
    elif find . -maxdepth 3 -type f \( -name '*.sln' -o -name '*.csproj' \) -print -quit 2>/dev/null | grep -q .; then
        printf '.NET'
    elif [[ -f package.json ]]; then
        printf 'Node'
    elif [[ -f pyproject.toml || -f requirements.txt ]]; then
        printf 'Python'
    else
        printf 'Generic Git repository'
    fi
}

# Pick a useful source root for the detected project type.
detect_code_root() {
    local project_type="$1"

    case "$project_type" in
        Unity)   [[ -d Assets ]] && printf 'Assets' || printf '.' ;;
        Flutter) [[ -d lib ]] && printf 'lib' || printf '.' ;;
        Android) [[ -d app/src/main ]] && printf 'app/src/main' || printf '.' ;;
        Unreal)  [[ -d Source ]] && printf 'Source' || printf '.' ;;
        Node)    [[ -d src ]] && printf 'src' || printf '.' ;;
        Python)  [[ -d src ]] && printf 'src' || printf '.' ;;
        *)       printf '.' ;;
    esac
}
