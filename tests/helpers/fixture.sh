#!/usr/bin/env bash

fixture_copy() {
    local fixture_name="$1"
    local destination="$2"
    local fixture_root="${TEST_DIR}/fixtures/${fixture_name}"
    [[ -d "$fixture_root" ]] || { printf 'Fixture not found: %s\n' "$fixture_name" >&2; return 1; }
    mkdir -p "$destination"
    cp -R "$fixture_root/." "$destination/"
}

fixture_init_git() {
    local repository="$1"
    git -C "$repository" init -q
    git -C "$repository" config user.name 'Fixture Author'
    git -C "$repository" config user.email 'fixture@example.test'
}

fixture_commit_as() {
    local repository="$1" name="$2" email="$3" message="$4"
    git -C "$repository" add .
    git -C "$repository" -c user.name="$name" -c user.email="$email" commit -qm "$message"
}
