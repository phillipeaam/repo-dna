# Directory and File Exclusion System

## Overview

The DNA analysis script now uses a **centralized exclusion system** to prevent repeated analysis of ignored directories. This ensures consistent filtering across all file discovery and search operations.

## How It Works

### 1. Built-in Ignored Directories

The script includes a hardcoded list of common directories to ignore:

```bash
IGNORED_DIRS=(
  Library Logs Temp Obj Build Builds UserSettings MemoryCaptures
  node_modules vendor Packages .git
)
```

These are automatically excluded from:
- `find` operations via the `analysis_find()` function
- `grep` recursive searches via the `analysis_grep()` function

### 2. The `.repodnaignore` File

Create a `.repodnaignore` file in your repository root to add custom directory exclusions. It intentionally supports a smaller contract than `.gitignore`:

**Example `.repodnaignore`:**
```
# Third-party and vendor directories
Plugins/
ThirdParty/
Third-Party/
External/
Vendor/
SDK/
AssetStore/
AssetsStore/
Packages/

# Generated directories
Generated/

# Build outputs
bin/
obj/
```

**Key Differences from `.gitignore`:**
- Only directory entries ending with `/` are supported.
- File globs and negation rules are not currently supported.
- Unsupported patterns should not be listed because documentation alone does
  not exclude content from generated reports.

## Centralized Functions

### `analysis_find()`
Use this function for all file discovery instead of `find` directly:

```bash
# Find all C# files in the project
analysis_find -type f -iname '*.cs' -print

# Find scenes and prefabs
analysis_find -type f \( -iname '*.unity' -o -iname '*.prefab' \) -print
```

**What it excludes:**
- All directories in `IGNORED_DIRS`
- All directories listed in `.repodnaignore` (entries ending with `/`)
- Git metadata (`.git/*`)
- Output directories for this analysis run

### `analysis_grep()`
Use this function for all recursive grep searches instead of `grep -R` directly:

```bash
# Search for interfaces in C# files
analysis_grep \
    --include='*.cs' \
    -InE \
    '^[[:space:]]*(public|internal|protected|private)?[[:space:]]*interface[[:space:]]+' \
    > results.txt
```

**What it excludes:**
- All directories in `IGNORED_DIRS`
- All directories listed in `.repodnaignore` (entries ending with `/`)

## Benefits

### Before
```bash
# Multiple places checking different sets of ignored directories
grep -R "pattern" "$CODE_ROOT"  # No exclusions!
find "$CODE_ROOT" ...           # Partial exclusions
grep -R "pattern" "$CODE_ROOT"  # Different exclusions!
```

**Problems:**
- Plugins, generated code, and vendored libraries get analyzed repeatedly
- Inconsistent exclusion logic across the codebase
- Hard to maintain: adding new ignored directories requires updating multiple places

### After
```bash
# Single source of truth
analysis_find -type f -iname '*.cs'         # Uses all exclusions
analysis_grep --include='*.cs' -InE 'pattern'  # Uses all exclusions
```

**Benefits:**
- ✅ All file discovery uses the same exclusion rules
- ✅ Easy to customize via `.repodnaignore`
- ✅ No duplicate analysis of third-party or generated code
- ✅ Maintainable: add exclusions in one place

## Migration Guide

If you have existing scripts using direct `find` or `grep -R`:

**Before:**
```bash
grep -RInE "pattern" "$CODE_ROOT" --include='*.cs' > output.txt
find "$CODE_ROOT" -type f -iname '*.cs' -print
```

**After:**
```bash
analysis_grep --include='*.cs' -InE "pattern" > output.txt
analysis_find -type f -iname '*.cs' -print
```

## Examples

### Finding all MonoBehaviours
```bash
analysis_grep \
    --include='*.cs' \
    -InE \
    ':[[:space:]]*MonoBehaviour' \
    > monobehaviours.txt
```

### Finding files by name pattern
```bash
analysis_find -type f -iname '*Controller*.cs' -print
```

### Counting C# files
```bash
analysis_find -type f -iname '*.cs' -print | wc -l
```

### Finding recent changes in non-ignored code
```bash
# Get all modified files from git
git diff --name-only HEAD~1 |

# Filter through analysis_find to remove ignored paths
while read file; do
    analysis_find -type f -path "$file" && echo "$file"
done
```

## Performance Notes

- The `.repodnaignore` file is read on every function call for consistency
- For large exclusion lists, consider batching operations to minimize I/O
- `grep --exclude-dir` is highly efficient for large codebases

## Troubleshooting

### My exclusions aren't working
1. Check that `.repodnaignore` is in the repository root
2. Ensure directory entries end with `/`
3. Verify no trailing whitespace in patterns
4. Lines starting with `#` are treated as comments

### Still analyzing plugins/generated code
1. Add the directory to `.repodnaignore` with a trailing `/`
2. Or add the directory name to `IGNORED_DIRS` in the script if it's universal
3. Test with: `analysis_find -type d -name "YourDir"`

### Performance is slow
- Use `analysis_grep` instead of piping through `analysis_find` to `grep`
- Limit file types with `--include` in `analysis_grep`
- Consider splitting analysis by file type
