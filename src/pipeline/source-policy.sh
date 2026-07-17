apply_source_policy() {
echo "[5/12] Applying source export and privacy policy..."

if [[ "$INCLUDE_SOURCE" == true ]]; then
    while IFS= read -r source_file; do
        copy_preserving_path "$source_file" "$SOURCE_DIR/reviewable_csharp"
    done < <(
        analysis_find -type f -iname '*.cs' -print 2>/dev/null |
            while IFS= read -r source_file; do
                ownership_is_reviewable "$source_file" && printf '%s\n' "$source_file"
            done |
            sort
    )

    while IFS= read -r source_file; do
        copy_preserving_path "$source_file" "$SOURCE_DIR/likely_project_owned"
    done < <(
        analysis_find -type f -iname '*.cs' -print 2>/dev/null |
            while IFS= read -r source_file; do
                ownership_is_project_owned "$source_file" && printf '%s\n' "$source_file"
            done |
            sort
    )
fi

if [[ "$PRIVACY_MODE" != strict ]]; then
    git ls-files -z -- 'README*' '*.md' 2>/dev/null |
        while IFS= read -r -d '' documentation_file; do
            copy_preserving_path "$documentation_file" "$SOURCE_DIR/documentation"
        done

    find ProjectSettings -maxdepth 1 -type f \( \
            -iname '*.asset' -o \
            -iname '*.txt' -o \
            -iname '*.json' \
        \) 2>/dev/null |
        while IFS= read -r settings_file; do
            cp "$settings_file" "$SOURCE_DIR/project_settings/"
        done
fi

# Print the sixth progress step.
}
