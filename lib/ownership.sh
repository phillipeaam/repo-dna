#!/usr/bin/env bash

# Evidence-based source ownership classification.

declare -a OWNERSHIP_SUBMODULE_ROOTS=()
declare -a OWNERSHIP_ASMDEF_ROOTS=()
declare -a OWNERSHIP_DEPENDENCY_ROOTS=()
declare -a OWNERSHIP_IGNORED_ROOTS=()
declare -A OWNERSHIP_TRACKED_PATHS=()

ownership_normalize_path() {
    local path="${1#./}"
    path="${path%/}"
    printf '%s' "${path:-.}"
}

ownership_path_is_under() {
    local path
    local root
    path="$(ownership_normalize_path "$1")"
    root="$(ownership_normalize_path "$2")"

    [[ "$root" == . || "$path" == "$root" || "$path" == "$root/"* ]]
}

ownership_matches_any_root() {
    local path="$1"
    shift
    local root

    for root in "$@"; do
        ownership_path_is_under "$path" "$root" && return 0
    done

    return 1
}

ownership_initialize() {
    local path

    while IFS= read -r path; do
        [[ -n "$path" ]] && OWNERSHIP_IGNORED_ROOTS+=("$(ownership_normalize_path "$path")")
    done < <(_load_repodna_ignore_directories)

    while IFS= read -r path; do
        [[ -n "$path" ]] && OWNERSHIP_TRACKED_PATHS["$(ownership_normalize_path "$path")"]=1
    done < <(git ls-files 2>/dev/null)

    if [[ -f .gitmodules ]]; then
        while IFS= read -r path; do
            [[ -n "$path" ]] && OWNERSHIP_SUBMODULE_ROOTS+=("$(ownership_normalize_path "$path")")
        done < <(git config --file .gitmodules --get-regexp 'submodule\..*\.path' 2>/dev/null | awk '{ print $2 }')
    fi

    while IFS= read -r path; do
        [[ -n "$path" ]] && OWNERSHIP_ASMDEF_ROOTS+=("$(dirname "$(ownership_normalize_path "$path")")")
    done < <(analysis_find -maxdepth 6 -type f -name '*.asmdef' -print 2>/dev/null)

    # Package-manager roots are backed by dependency manifests when present.
    [[ -f Packages/manifest.json ]] && OWNERSHIP_DEPENDENCY_ROOTS+=(Packages)
    [[ -f package.json ]] && OWNERSHIP_DEPENDENCY_ROOTS+=(node_modules)
    [[ -f composer.json ]] && OWNERSHIP_DEPENDENCY_ROOTS+=(vendor)
}

ownership_is_ignored() {
    local path="$1"
    local ignored

    for ignored in "${OWNERSHIP_IGNORED_ROOTS[@]}"; do
        if [[ "$ignored" == */* ]]; then
            ownership_path_is_under "$path" "$ignored" && return 0
        elif [[ "/$path/" == *"/$ignored/"* ]]; then
            return 0
        fi
    done

    return 1
}

ownership_has_external_header() {
    local path="$1"
    [[ -f "$path" ]] || return 1

    head -n 40 "$path" 2>/dev/null |
        grep -Eiq 'copyright|SPDX-License-Identifier|licensed under|all rights reserved'
}

# Set OWNERSHIP_CLASS, OWNERSHIP_CONFIDENCE, and OWNERSHIP_REASON for one path.
classify_ownership() {
    local path
    path="$(ownership_normalize_path "$1")"

    if ownership_is_ignored "$path"; then
        OWNERSHIP_CLASS='excluded'
        OWNERSHIP_CONFIDENCE='High'
        OWNERSHIP_REASON='.repodnaignore'
    elif [[ "$path" =~ (^|/)(Generated|gen|obj|bin)(/|$) ]] ||
         [[ "$path" =~ (\.generated\.cs|\.gen\.cs|_generated\.cs)$ ]]; then
        OWNERSHIP_CLASS='generated'
        OWNERSHIP_CONFIDENCE='High'
        OWNERSHIP_REASON='known generated path or filename'
    elif ownership_matches_any_root "$path" "${OWNED_ROOTS[@]}"; then
        OWNERSHIP_CLASS='project-owned'
        OWNERSHIP_CONFIDENCE='High'
        OWNERSHIP_REASON='manual --owned-root'
    elif ownership_matches_any_root "$path" "${OWNERSHIP_SUBMODULE_ROOTS[@]}"; then
        OWNERSHIP_CLASS='third-party'
        OWNERSHIP_CONFIDENCE='High'
        OWNERSHIP_REASON='Git submodule'
    elif [[ "$path" =~ (^|/)(Plugins|ThirdParty|Third-Party|External|Vendor|SDK|AssetStore|AssetsStore)(/|$) ]]; then
        OWNERSHIP_CLASS='third-party'
        OWNERSHIP_CONFIDENCE='High'
        OWNERSHIP_REASON='known external path'
    elif ownership_matches_any_root "$path" "${OWNERSHIP_DEPENDENCY_ROOTS[@]}"; then
        OWNERSHIP_CLASS='third-party'
        OWNERSHIP_CONFIDENCE='High'
        OWNERSHIP_REASON='dependency-manifest package root'
    elif ownership_has_external_header "$path"; then
        OWNERSHIP_CLASS='review-required'
        OWNERSHIP_CONFIDENCE='Medium'
        OWNERSHIP_REASON='copyright or license header'
    elif ownership_matches_any_root "$path" "${OWNERSHIP_ASMDEF_ROOTS[@]}"; then
        OWNERSHIP_CLASS='project-owned'
        OWNERSHIP_CONFIDENCE='Medium'
        OWNERSHIP_REASON='assembly definition and no external signal'
    elif [[ -n "${OWNERSHIP_TRACKED_PATHS[$path]+present}" ]]; then
        OWNERSHIP_CLASS='project-owned'
        OWNERSHIP_CONFIDENCE='Low'
        OWNERSHIP_REASON='tracked file with no stronger signal'
    else
        OWNERSHIP_CLASS='review-required'
        OWNERSHIP_CONFIDENCE='Low'
        OWNERSHIP_REASON='no decisive ownership evidence'
    fi
}

ownership_is_project_owned() {
    classify_ownership "$1"
    [[ "$OWNERSHIP_CLASS" == project-owned ]]
}

ownership_is_reviewable() {
    classify_ownership "$1"
    [[ "$OWNERSHIP_CLASS" == project-owned || "$OWNERSHIP_CLASS" == review-required ]]
}

write_ownership_report() {
    local output_file="$1"
    local path

    {
        printf '%s\n' 'Ownership classification'
        printf '%s\n' '------------------------'

        {
            printf '%s\n' "${OWNED_ROOTS[@]}"
            printf '%s\n' "${OWNERSHIP_SUBMODULE_ROOTS[@]}"
            printf '%s\n' "${OWNERSHIP_ASMDEF_ROOTS[@]}"
            printf '%s\n' "${OWNERSHIP_DEPENDENCY_ROOTS[@]}"
            printf '%s\n' "${OWNERSHIP_IGNORED_ROOTS[@]}"
            analysis_find -maxdepth 5 -type f \( -name '*.cs' -o -name '*.asmdef' \) -print 2>/dev/null |
                while IFS= read -r path; do dirname "$(ownership_normalize_path "$path")"; done
        } | awk 'NF' | sort -u |
            while IFS= read -r path; do
                classify_ownership "$path"
                printf '%-40s %s confidence: %s (%s)\n' \
                    "$(ownership_normalize_path "$path")/" \
                    "$OWNERSHIP_CONFIDENCE" \
                    "$OWNERSHIP_CLASS" \
                    "$OWNERSHIP_REASON"
            done
    } > "$output_file"
}
