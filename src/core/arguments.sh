#!/usr/bin/env bash

show_usage() {
    printf '%s\n' \
        'Usage:' '  bash dna-analysis.sh [options]' '' 'Options:' \
        '  --author <name-or-email>  Analyze one contributor instead of all history.' \
        '  --since <date>            Include commits on or after this date.' \
        '  --until <date>            Include commits on or before this date.' \
        '  --owned-root <path>       Mark a path as project-owned (repeatable).' \
        '  --portfolio-profile <file>  Add personally confirmed portfolio claims.' \
        '  --include-source          Copy classified C# source into the report.' \
        '  --privacy-mode <mode>     Privacy level: standard or strict.' \
        '  -h, --help                Show this help.' '' 'Examples:' \
        '  bash dna-analysis.sh' \
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
    PRIVACY_MODE='standard'
    PORTFOLIO_PROFILE=''
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --author|--since|--until|--owned-root|-owned-root|--privacy-mode|--portfolio-profile)
                [[ -n "${2:-}" ]] || die "Option $1 requires a value."
                case "$1" in
                    --author) AUTHOR="$2" ;;
                    --since) SINCE="$2" ;;
                    --until) UNTIL="$2" ;;
                    --owned-root|-owned-root) OWNED_ROOTS+=("${2#./}") ;;
                    --privacy-mode) PRIVACY_MODE="$2" ;;
                    --portfolio-profile) PORTFOLIO_PROFILE="$2" ;;
                esac
                shift 2 ;;
            --include-source) INCLUDE_SOURCE=true; shift ;;
            -h|--help) show_usage; exit 0 ;;
            *) show_usage >&2; die "Unknown option: $1" ;;
        esac
    done
    [[ "$PRIVACY_MODE" == standard || "$PRIVACY_MODE" == strict ]] ||
        die "Invalid privacy mode: $PRIVACY_MODE (expected standard or strict)."
    [[ "$PRIVACY_MODE" != strict || -z "$PORTFOLIO_PROFILE" ]] ||
        die "--portfolio-profile cannot be used with strict privacy mode."
    [[ "$PRIVACY_MODE" != strict ]] || INCLUDE_SOURCE=false
}
