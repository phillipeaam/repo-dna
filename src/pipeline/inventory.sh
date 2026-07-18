collect_inventory() {
log_info "Exporting project structure and asset inventories"

# Export a project tree without requiring the tree command, respecting exclusions.
analysis_find -type f -print 2>/dev/null |
    sed 's|^\./||' |
    sort \
    > "$PROJECT_DIR/01_folder_tree.txt"

# Export primary source directories.
analysis_find -mindepth 1 -maxdepth 2 -type d -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/02_main_directories.txt"

collect_unity_assets

# Export likely third-party files.
while IFS= read -r source_file; do
    classify_ownership "$source_file"
    if [[ "$OWNERSHIP_CLASS" == third-party ]]; then
        printf '%s\t%s confidence\t%s\n' \
            "$source_file" "$OWNERSHIP_CONFIDENCE" "$OWNERSHIP_REASON"
    fi
done < <(analysis_find -type f -print 2>/dev/null) |
    sort > "$PROJECT_DIR/12_likely_third_party_files.txt"

# Summarize directory ownership with confidence and supporting evidence.
write_ownership_report "$PROJECT_DIR/12_ownership_classification.txt"

# Print the third progress step.
}
