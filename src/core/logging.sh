#!/usr/bin/env bash

readonly REPODNA_LOG_ERROR=0 REPODNA_LOG_WARN=1 REPODNA_LOG_INFO=2
readonly REPODNA_LOG_DEBUG=3 REPODNA_LOG_TRACE=4

log_level_number() {
    case "${1^^}" in ERROR) printf 0;; WARN) printf 1;; INFO) printf 2;; DEBUG) printf 3;; TRACE) printf 4;; *) printf 2;; esac
}

sanitize_log_message() {
    sed -E \
        -e 's#(https?|ssh)://[^[:space:]]+#[REDACTED_URL]#g' \
        -e 's#[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}#[REDACTED_EMAIL]#g' \
        -e 's#([Bb]earer[[:space:]]+)[[:alnum:]_.~+/=-]+#\1[REDACTED]#g' \
        -e 's#((api[_-]?key|token|password|passwd|pwd|secret)[[:space:]]*[:=][[:space:]]*)[^[:space:]]+#\1[REDACTED]#g' \
        -e 's#[A-Za-z]:[/\\][^[:space:]]+#[REDACTED_PATH]#g' \
        -e 's#(^|[[:space:]])/[^[:space:]]+#\1[REDACTED_PATH]#g'
}

logger_init() {
    REPODNA_LOG_LEVEL="${REPODNA_LOG_LEVEL:-INFO}"
    REPODNA_LOG_THRESHOLD="$(log_level_number "$REPODNA_LOG_LEVEL")"
    REPODNA_LOG_FILE=''
    REPODNA_PENDING_LOG="$(mktemp "${TMPDIR:-/tmp}/repodna-log.XXXXXX")" || return 1
}

logger_attach_file() {
    local target="$1"
    [[ "$REPODNA_LOG_THRESHOLD" -ge "$REPODNA_LOG_DEBUG" ]] || return 0
    mkdir -p "$(dirname "$target")" || return 1
    REPODNA_LOG_FILE="$target"
    [[ ! -s "$REPODNA_PENDING_LOG" ]] || cp "$REPODNA_PENDING_LOG" "$REPODNA_LOG_FILE"
}

logger_cleanup() { [[ -z "${REPODNA_PENDING_LOG:-}" ]] || rm -f "$REPODNA_PENDING_LOG"; }

log_emit() {
    local level="$1" message="$2" level_number sanitized timestamp line
    level_number="$(log_level_number "$level")"
    [[ "$level_number" -le "$REPODNA_LOG_THRESHOLD" ]] || return 0
    line="[$level] $message"
    if [[ "$level_number" -le "$REPODNA_LOG_WARN" ]]; then printf '%s\n' "$line" >&2; else printf '%s\n' "$line"; fi
    [[ "$REPODNA_LOG_THRESHOLD" -ge "$REPODNA_LOG_DEBUG" ]] || return 0
    sanitized="$(printf '%s' "$message" | sanitize_log_message)"
    timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf '%s [%s] %s\n' "$timestamp" "$level" "$sanitized" >> "${REPODNA_LOG_FILE:-$REPODNA_PENDING_LOG}"
}

log_error() { log_emit ERROR "$*"; }
log_warn() { log_emit WARN "$*"; }
log_info() { log_emit INFO "$*"; }
log_debug() { log_emit DEBUG "$*"; }
log_trace() { log_emit TRACE "$*"; }
