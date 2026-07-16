# 🐚 Bash Cheat Sheet

A quick reference for Bash syntax and commands used throughout the **RepoDNA** codebase.

> **Note:** RepoDNA is written in **Bash**, not generic POSIX Shell, and therefore uses Bash-specific features such as `[[ ]]`, arrays, and `local` variables.

---

# Table of Contents

- [Variables](#variables)
- [Variable Declaration (`declare`)](#variable-declaration-declare)
- [Parameter Expansion](#parameter-expansion)
- [Conditions](#conditions)
- [Files and Directories](#files-and-directories)
- [Strings](#strings)
- [Operators](#operators)
- [Regular Expressions (Regex)](#regular-expressions-regex)
- [Functions](#functions)
- [Loops](#loops)
- [Reading Files](#reading-files)
- [Command Execution](#command-execution)
- [Exit Codes](#exit-codes)
- [Arguments](#arguments)
- [Useful Commands](#useful-commands)
- [Bash vs C#](#bash-vs-c)

---

# Variables

```bash
name="RepoDNA"

echo "$name"
```

Equivalent (C#):

```csharp
string name = "RepoDNA";
Console.WriteLine(name);
```

---

# Variable Declaration (`declare`)

The `declare` builtin allows variables to have attributes such as arrays, integers, read-only, or name references.

General syntax:

```bash
declare [options] variable=value
```

---

## Common Options

| Option | Meaning | Example |
|---------|---------|---------|
| `-a` | Indexed array | `declare -a files` |
| `-A` | Associative array (dictionary) | `declare -A map` |
| `-i` | Integer variable | `declare -i count=10` |
| `-r` | Read-only variable | `declare -r VERSION="1.0"` |
| `-x` | Export variable to child processes | `declare -x PATH` |
| `-n` | Name reference (reference another variable) | `declare -n ref=array` |
| `-p` | Print variable declaration | `declare -p PATH` |

---

## Read-only Array

```bash
declare -ar IGNORED_DIRS=(
    Library
    Temp
    Logs
)
```

Meaning:

- `-a` → Indexed array
- `-r` → Read-only

The array cannot be modified later.

Equivalent (conceptually):

```csharp
readonly string[] ignoredDirs =
{
    "Library",
    "Temp",
    "Logs"
};
```

---

## Indexed Array

```bash
declare -a files

files+=("Player.cs")
files+=("Enemy.cs")
```

Equivalent:

```csharp
var files = new List<string>();

files.Add("Player.cs");
files.Add("Enemy.cs");
```

---

## Associative Array

```bash
declare -A extensions

extensions[Unity]=".cs"
extensions[Android]=".kt"
```

Equivalent:

```csharp
var extensions = new Dictionary<string, string>();

extensions["Unity"] = ".cs";
extensions["Android"] = ".kt";
```

---

## Integer Variable

```bash
declare -i count=5

count+=3
```

Output:

```text
8
```

Without `-i`, Bash treats variables as strings.

Equivalent:

```csharp
int count = 5;
count += 3;
```

---

## Read-only Variable

```bash
declare -r VERSION="1.0"
```

Trying to modify it:

```bash
VERSION="2.0"
```

Produces:

```text
bash: VERSION: readonly variable
```

Equivalent:

```csharp
const string VERSION = "1.0";
```

---

## Name Reference (`-n`)

A name reference points to another variable.

```bash
declare -n ref=array
```

Now:

```bash
ref+=("Player.cs")
```

actually modifies:

```bash
array
```

RepoDNA uses this pattern:

```bash
build_find_prune_predicates() {
    local -n predicates="$1"

    predicates+=(
        -path "*/Library"
    )
}
```

Usage:

```bash
local -a prune=()

build_find_prune_predicates prune
```

After the function returns:

```bash
echo "${prune[@]}"
```

contains all generated predicates.

Equivalent (conceptually):

```csharp
void Build(ref List<string> predicates)
{
    predicates.Add("...");
}
```

---

## Print Variable Information

```bash
declare -p IGNORED_DIRS
```

Output:

```text
declare -ar IGNORED_DIRS=([0]="Library" [1]="Temp")
```

Useful for debugging.

---

## Notes

- `declare` is a Bash builtin.
- `local` supports most of the same options inside functions.
- `declare -n` requires **Bash 4.3+**.
- Arrays are one of Bash's most powerful features and should be preferred over building command strings.

---

# Parameter Expansion

Parameter Expansion is one of Bash's most powerful features. It allows manipulating variables without calling external tools such as `sed`, `awk`, or `cut`, making scripts faster and more idiomatic.

General syntax:

```bash
${variable<operator>pattern}
```

---

## Common Operations

| Bash | Meaning | C# Equivalent |
|------|---------|---------------|
| `${var}` | Variable value | `variable` |
| `${#var}` | String length | `variable.Length` |
| `${var%pattern}` | Remove the shortest matching suffix | `TrimEnd()` / `Substring()` |
| `${var%%pattern}` | Remove the longest matching suffix | Regex / `LastIndexOf()` |
| `${var#pattern}` | Remove the shortest matching prefix | `TrimStart()` / `Substring()` |
| `${var##pattern}` | Remove the longest matching prefix | Regex / `LastIndexOf()` |
| `${var/p1/p2}` | Replace the first occurrence | `Replace(..., ..., 1)` *(conceptually)* |
| `${var//p1/p2}` | Replace all occurrences | `Replace()` |
| `${var:-default}` | Use a default value if empty or unset | `string.IsNullOrEmpty(var) ? default : var` |

---

## Examples

### Remove a trailing slash

```bash
pattern="Assets/"

echo "${pattern%/}"
```

Output:

```text
Assets
```

Equivalent:

```csharp
pattern = pattern.TrimEnd('/');
```

---

### Remove a file extension

```bash
file="Player.cs"

echo "${file%.cs}"
```

Output:

```text
Player
```

---

### Remove everything after the last slash

```bash
path="Assets/Scripts/Player.cs"

echo "${path##*/}"
```

Output:

```text
Player.cs
```

Equivalent:

```csharp
Path.GetFileName(path);
```

---

### Get the directory name

```bash
path="Assets/Scripts/Player.cs"

echo "${path%/*}"
```

Output:

```text
Assets/Scripts
```

Equivalent:

```csharp
Path.GetDirectoryName(path);
```

---

### Replace all spaces

```bash
text="Hello World"

echo "${text// /_}"
```

Output:

```text
Hello_World
```

Equivalent:

```csharp
text.Replace(" ", "_");
```

---

### Get string length

```bash
text="RepoDNA"

echo "${#text}"
```

Output:

```text
7
```

Equivalent:

```csharp
text.Length;
```

---

## RepoDNA Example

Normalize directory patterns by removing a trailing slash:

```bash
if [[ "$pattern" == */ ]]; then
    pattern="${pattern%/}"
fi
```

Equivalent:

```csharp
if (pattern.EndsWith("/"))
{
    pattern = pattern.TrimEnd('/');
}
```

---

## Notes

- Parameter Expansion is performed by **Bash itself**.
- No external processes are started.
- It is generally faster than invoking tools like `sed`, `cut`, or `awk` for simple string manipulation.
- Pattern matching uses **shell glob patterns**, not regular expressions.

---

## Default Values

Parameter Expansion can also provide fallback values when variables are **unset** or **empty**.

### Use a default value

```bash
echo "${name:-Guest}"
```

If `name` is unset or empty:

```text
Guest
```

Equivalent:

```csharp
Console.WriteLine(string.IsNullOrEmpty(name) ? "Guest" : name);
```

---

### Example

```bash
username=""
echo "${username:-anonymous}"
```

Output:

```text
anonymous
```

---

### Provide a default path

```bash
OUTPUT_DIR="${OUTPUT_DIR:-./output}"
```

Equivalent:

```csharp
OUTPUT_DIR = string.IsNullOrEmpty(OUTPUT_DIR)
    ? "./output"
    : OUTPUT_DIR;
```

---

## Related Operators

| Bash | Meaning | Notes |
|------|---------|-------|
| `${var:-default}` | Use `default` if variable is unset **or** empty | Does **not** modify the variable |
| `${var-default}` | Use `default` only if variable is unset | Empty string is considered a valid value |
| `${var:=default}` | Assign `default` if variable is unset or empty | Updates the variable |
| `${var=default}` | Assign `default` only if variable is unset | Empty string is preserved |
| `${var:?message}` | Abort with an error if variable is unset or empty | Useful for required configuration |
| `${var:+value}` | Use `value` only if variable is set and not empty | Commonly used for optional arguments |

---

### Assign a default value

```bash
LOG_LEVEL="${LOG_LEVEL:=INFO}"
```

If `LOG_LEVEL` was empty or unset:

```text
INFO
```

After expansion:

```bash
echo "$LOG_LEVEL"
```

Output:

```text
INFO
```

---

### Require a variable

```bash
: "${REPO_ROOT:?REPO_ROOT must be defined}"
```

If `REPO_ROOT` is missing:

```text
bash: REPO_ROOT: REPO_ROOT must be defined
```

Equivalent:

```csharp
if (string.IsNullOrEmpty(REPO_ROOT))
    throw new InvalidOperationException("REPO_ROOT must be defined");
```

---

# Conditions

```bash
if [[ "$name" == "RepoDNA" ]]; then
    echo "Match"
fi
```

Equivalent:

```csharp
if (name == "RepoDNA")
{
    Console.WriteLine("Match");
}
```

---

# Files and Directories

| Bash | Meaning | C# Equivalent |
|------|---------|---------------|
| `[[ -f file ]]` | File exists | `File.Exists()` |
| `[[ -d dir ]]` | Directory exists | `Directory.Exists()` |
| `[[ -e path ]]` | File or directory exists | `File.Exists()` || Directory.Exists()` |
| `[[ -s file ]]` | File exists and is not empty | `FileInfo.Length > 0` |
| `[[ -r file ]]` | File is readable | OpenRead() |
| `[[ -w file ]]` | File is writable | OpenWrite() |
| `[[ -x file ]]` | File is executable | N/A |

Example:

```bash
if [[ -f "$config_file" ]]; then
    echo "Config found."
fi
```

---

# Strings

| Bash | Meaning | C# Equivalent |
|------|---------|---------------|
| `[[ -n "$text" ]]` | String is NOT empty | `!string.IsNullOrEmpty()` |
| `[[ -z "$text" ]]` | String IS empty | `string.IsNullOrEmpty()` |

Example:

```bash
[[ -n "$author" ]] || return 0
```

Equivalent:

```csharp
if (string.IsNullOrEmpty(author))
    return;
```

---

# Operators

| Bash | Meaning | C# |
|-----|---------|----|
| `==` | Equals | `==` |
| `!=` | Not equals | `!=` |
| `&&` | Logical AND | `&&` |
| `\|\|` | Logical OR | `\|\|` |
| `!` | Logical NOT | `!` |

---

# Regular Expressions (Regex)

Bash supports regular expressions using the `=~` operator inside `[[ ]]`.

```bash
[[ "$text" =~ regex ]]
```

Equivalent:

```csharp
Regex.IsMatch(text, @"regex");
```

---

## Common Patterns

| Regex | Meaning |
|--------|---------|
| `^` | Beginning of the line |
| `$` | End of the line |
| `.` | Any character |
| `.*` | Zero or more of any character |
| `+` | One or more |
| `*` | Zero or more |
| `?` | Zero or one |
| `[abc]` | One of the listed characters |
| `[^abc]` | Any character except those listed |
| `[0-9]` | Any digit |
| `[A-Za-z]` | Any letter |
| `[[:space:]]` | Any whitespace (space, tab, etc.) |
| `[[:digit:]]` | Any digit |
| `[[:alpha:]]` | Any alphabetic character |
| `[[:alnum:]]` | Any alphanumeric character |

---

## Examples

Check if a filename ends with `.cs`

```bash
[[ "$file" =~ \.cs$ ]]
```

Equivalent:

```csharp
Regex.IsMatch(file, @"\.cs$")
```

---

Check if a line starts with a comment (`#`)

```bash
[[ "$line" =~ ^[[:space:]]*# ]]
```

Equivalent:

```csharp
Regex.IsMatch(line, @"^\s*#")
```

---

Check if a string contains only digits

```bash
[[ "$value" =~ ^[0-9]+$ ]]
```

Equivalent:

```csharp
Regex.IsMatch(value, @"^\d+$")
```

---

Check if a path starts with `Assets/`

```bash
[[ "$path" =~ ^Assets/ ]]
```

Equivalent:

```csharp
Regex.IsMatch(path, @"^Assets/")
```

---

## Ignoring Comments

A common RepoDNA pattern:

```bash
[[ "$pattern" =~ ^[[:space:]]*# ]] && continue
```

Meaning:

> If the line starts with optional whitespace followed by `#`, skip it.

Equivalent:

```csharp
if (Regex.IsMatch(pattern, @"^\s*#"))
    continue;
```

---

## Notes

- `=~` performs **regex matching**, not string comparison.
- Regex should **not** be quoted:
  ```bash
  [[ "$text" =~ ^Player ]]
  ```
  ✅ Correct

  ```bash
  [[ "$text" =~ "^Player" ]]
  ```
  ❌ Incorrect (treated as a literal string)

- Bash uses **POSIX Extended Regular Expressions (ERE)**, which differ slightly from .NET regular expressions.

# Functions

```bash
print_header() {
    echo "RepoDNA"
}
```

Equivalent:

```csharp
void PrintHeader()
{
    Console.WriteLine("RepoDNA");
}
```

---

# Local Variables

```bash
my_function() {
    local output_file="report.md"
}
```

Equivalent:

```csharp
void MyFunction()
{
    string outputFile = "report.md";
}
```

---

# Loops

## For

```bash
for file in *.cs; do
    echo "$file"
done
```

Equivalent:

```csharp
foreach (var file in files)
{
}
```

---

## While

```bash
while condition; do
    ...
done
```

Equivalent:

```csharp
while(condition)
{
}
```

---

# Reading Files

RepoDNA frequently reads configuration files line by line.

```bash
while IFS= read -r line || [[ -n "$line" ]]; do
    echo "$line"
done < "$config_file"
```

Explanation:

- `IFS=` preserves leading/trailing spaces.
- `read -r` prevents backslash escaping.
- `|| [[ -n "$line" ]]` ensures the last line is processed even if the file does not end with a newline.

Equivalent:

```csharp
foreach (var line in File.ReadLines(configFile))
{
}
```

---

# Command Execution

Run a command:

```bash
git status
```

Capture output:

```bash
current_branch=$(git branch --show-current)
```

Equivalent:

```csharp
var currentBranch = RunCommand("git branch --show-current");
```

---

# Exit Codes

Unlike C#, Bash relies heavily on command exit codes.

```
0 = Success
1+ = Failure
```

Example:

```bash
git diff --quiet
```

Returns:

```
0 -> No changes
1 -> Changes detected
```

---

# Arguments

```
$0 -> Script name
$1 -> First argument
$2 -> Second argument
$@ -> All arguments
$# -> Number of arguments
$? -> Exit code of previous command
```

Example:

```bash
echo "$1"
```

Equivalent:

```csharp
Console.WriteLine(args[0]);
```

---

# Useful Commands

| Command | Description |
|----------|-------------|
| `find` | Search files |
| `grep` | Search text |
| `awk` | Text processing |
| `sed` | Stream editor |
| `sort` | Sort lines |
| `uniq` | Remove duplicates |
| `cut` | Split columns |
| `tr` | Replace characters |
| `tar` | Archive files |
| `zip` | Compress files |
| `git` | Version control |

---

# File Descriptors (FD)

***Rule of Thumb: Whenever you see <, >, 2>, 2>&1, <(...), or >(...), you're working with file descriptors and stream redirection.***

In Unix-like systems, everything is treated as a file. Every process starts with three standard file descriptors.

| FD | Name | Purpose |
|----|------|---------|
| `0` | Standard Input (`stdin`) | Read input from the user or another process |
| `1` | Standard Output (`stdout`) | Normal program output |
| `2` | Standard Error (`stderr`) | Error messages |

---

## Standard Output (stdout)

```bash
echo "Hello"
```

Equivalent:

```csharp
Console.WriteLine("Hello");
```

---

## Standard Error (stderr)

Send a message to the error stream instead of standard output.

```bash
printf 'Something went wrong\n' >&2
```

Equivalent:

```csharp
Console.Error.WriteLine("Something went wrong");
```

---

## Redirect stdout

Write normal output to a file.

```bash
echo "Hello" > output.txt
```

Equivalent:

```csharp
File.WriteAllText("output.txt", "Hello");
```

---

## Append stdout

Append instead of overwriting.

```bash
echo "Hello" >> output.txt
```

Equivalent:

```csharp
File.AppendAllText("output.txt", "Hello");
```

---

## Redirect stderr

Capture only errors.

```bash
command 2> errors.log
```

---

## Redirect stdout and stderr separately

```bash
command > output.log 2> errors.log
```

---

## Redirect both stdout and stderr

```bash
command > all.log 2>&1
```

Explanation:

```text
stdout (1) ─┐
            ├──► all.log
stderr (2) ┘
```

---

## Discard output

Ignore all output.

```bash
command > /dev/null
```

Ignore only errors.

```bash
command 2> /dev/null
```

Ignore everything.

```bash
command > /dev/null 2>&1
```

Equivalent:

```csharp
// Ignore output
```

---

## Read from stdin

```bash
read name
```

Equivalent:

```csharp
string name = Console.ReadLine();
```

---

## Here String

Pass a string as standard input.

```bash
grep "Unity" <<< "$text"
```

Equivalent:

```csharp
using var reader = new StringReader(text);
```

---

## Here Document

Provide multiple lines as input.

```bash
cat <<EOF
Hello
RepoDNA
EOF
```

Equivalent:

```csharp
string text = """
Hello
RepoDNA
""";
```

---

## Process Substitution

Use the output of a command as if it were a file.

```bash
diff <(ls dir1) <(ls dir2)
```

Equivalent:

```csharp
Compare(
    Directory.GetFiles("dir1"),
    Directory.GetFiles("dir2"));
```

RepoDNA uses this technique:

```bash
while IFS= read -r dir || [[ -n "$dir" ]]; do
    ...
done < <(_load_repodna_ignore_directories)
```

The command `_load_repodna_ignore_directories` is executed first, and its output becomes the input of the `while` loop.

---

## Common Redirection Operators

| Operator | Meaning |
|----------|---------|
| `>` | Redirect stdout (overwrite) |
| `>>` | Redirect stdout (append) |
| `2>` | Redirect stderr |
| `2>>` | Append stderr |
| `2>&1` | Redirect stderr to stdout |
| `<` | Read input from file |
| `<<` | Here Document |
| `<<<` | Here String |
| `<(...)` | Process Substitution |
| `>(...)` | Output Process Substitution |

---

## Notes

- `stdout` and `stderr` are independent streams.
- `stderr` is typically used for diagnostics and error messages.
- Redirecting output does **not** automatically redirect errors.
- Process substitution (`<(...)`) is a Bash feature and is not available in POSIX `sh`.

---

# Bash vs C#

| Bash | C# |
|------|----|
| Variable | Variable |
| Function | Method |
| Script | Console Application |
| `echo` | `Console.WriteLine()` |
| `read` | `Console.ReadLine()` |
| `find` | `Directory.EnumerateFiles()` |
| `grep` | `Regex` / `Contains()` |
| `return 0` | `return;` |
| `exit 0` | `Environment.Exit(0)` |
| `$(command)` | `RunProcess()` |
| `"$@"` | `string[] args` |

---

# Best Practices

✅ Always quote variables.

```bash
"$file"
```

instead of

```bash
$file
```

---

✅ Prefer `[[ ]]` over `[ ]` in Bash.

---

✅ Use `local` inside functions whenever possible.

---

✅ Always use:

```bash
read -r
```

instead of plain `read`.

---

✅ Use meaningful function names.

Good:

```bash
generate_git_report
```

Bad:

```bash
report2
```

---

✅ Keep functions small and focused.

---

✅ Return status codes instead of printing errors whenever possible.

---

# References

- https://www.gnu.org/software/bash/manual/bash.html
- https://mywiki.wooledge.org/BashGuide
- https://explainshell.com