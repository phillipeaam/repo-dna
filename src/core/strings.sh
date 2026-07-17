#!/usr/bin/env bash

# String utility helpers
# Safe to source from other scripts. Provides simple string functions
# used across production modules.

# Trim leading and trailing whitespace from a string argument.
# Usage: trimmed=$(string_trim "  value  ")
string_trim() {
    local s="$1"
    printf '%s' "$s" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
