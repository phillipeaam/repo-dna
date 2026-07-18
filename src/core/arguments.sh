#!/usr/bin/env bash

show_usage() {
    printf '%s\n' \
        'Usage:' '  bash dna-analysis.sh [repository] [options]' '' 'Options:' \
        '  --repository <path>      Analyze this repository instead of the current directory.' \
        '  --output <path>          Write the analysis to this new directory.' \
        '  --ignore-file <path>     Use a custom RepoDNA ignore file.' \
        '  --author <name-or-email>  Analyze one contributor instead of all history.' \
        '  --since <date>            Include commits on or after this date.' \
        '  --until <date>            Include commits on or before this date.' \
        '  --owned-root <path>       Mark a path as project-owned (repeatable).' \
        '  --portfolio-profile <file>  Add personally confirmed portfolio claims.' \
        '  --forge-data <file>       Import normalized issues, pull requests, and releases.' \
        '  --include-source          Copy classified C# source into the report.' \
        '  --no-graphs              Skip optional graph and chart generation.' \
        '  --no-history             Skip Git history collection.' \
        '  --save-snapshot           Persist a versioned snapshot under .repodna/snapshots.' \
        '  --compare-with <file>     Compare this run with a previous analysis snapshot.' \
        '  --privacy-mode <mode>     Privacy level: standard or strict.' \
        '  -h, --help                Show this help.' '' 'Examples:' \
        '  bash dna-analysis.sh' \
        '  bash /path/to/dna-analysis.sh "/c/Users/Name/Project"' \
        '  bash dna-analysis.sh --repository "C:\Users\Name\Project"' \
        '  bash dna-analysis.sh --author "Phillipe Augusto"' \
        '  bash dna-analysis.sh --since 2020-01-01 --until 2025-12-31' \
        '  bash dna-analysis.sh --owned-root Assets/_Project' \
        '  bash dna-analysis.sh --include-source' \
        '  bash dna-analysis.sh --privacy-mode strict'
}

parse_arguments() {
    AUTHOR=""
    SINCE=""
    UNTIL=""
    OWNED_ROOTS=()
    INCLUDE_SOURCE=false
    SAVE_SNAPSHOT=false
    COMPARE_WITH=''
    PRIVACY_MODE='standard'
    PORTFOLIO_PROFILE=''
    FORGE_DATA=''
    TARGET_REPOSITORY=''
    OUTPUT_OVERRIDE=''
    IGNORE_FILE=''
    NO_GRAPHS=false
    NO_HISTORY=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --repository|--output|--ignore-file|--author|--since|--until|--owned-root|-owned-root|--privacy-mode|--portfolio-profile|--compare-with|--forge-data)
                [[ -n "${2:-}" ]] || die "Option $1 requires a value." 2
                case "$1" in
                    --repository) TARGET_REPOSITORY="$2" ;;
                    --output) OUTPUT_OVERRIDE="$2" ;;
                    --ignore-file) IGNORE_FILE="$2" ;;
                    --author) AUTHOR="$2" ;;
                    --since) SINCE="$2" ;;
                    --until) UNTIL="$2" ;;
                    --owned-root|-owned-root) OWNED_ROOTS+=("${2#./}") ;;
                    --privacy-mode) PRIVACY_MODE="$2" ;;
                    --portfolio-profile) PORTFOLIO_PROFILE="$2" ;;
                    --compare-with) COMPARE_WITH="$2" ;;
                    --forge-data) FORGE_DATA="$2" ;;
                esac
                shift 2 ;;
            --include-source) INCLUDE_SOURCE=true; shift ;;
            --no-graphs) NO_GRAPHS=true; shift ;;
            --no-history) NO_HISTORY=true; shift ;;
            --save-snapshot) SAVE_SNAPSHOT=true; shift ;;
            -h|--help) show_usage; exit 0 ;;
            --*) show_usage >&2; die "Unknown option: $1" 2 ;;
            *)
                [[ -z "$TARGET_REPOSITORY" ]] || die "Only one repository path can be provided." 2
                TARGET_REPOSITORY="$1"; shift ;;
        esac
    done
    [[ "$PRIVACY_MODE" == standard || "$PRIVACY_MODE" == strict ]] ||
        die "Invalid privacy mode: $PRIVACY_MODE (expected standard or strict)." 2
    [[ "$PRIVACY_MODE" != strict || -z "$PORTFOLIO_PROFILE" ]] ||
        die "--portfolio-profile cannot be used with strict privacy mode." 2
    [[ "$PRIVACY_MODE" != strict ]] || INCLUDE_SOURCE=false
}
