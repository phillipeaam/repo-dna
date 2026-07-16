# 🐚 Bash Cheat Sheet

A quick reference for Bash syntax and commands used throughout the **RepoDNA** codebase.

> **Note:** RepoDNA is written in **Bash**, not generic POSIX Shell, and therefore uses Bash-specific features such as `[[ ]]`, arrays, and `local` variables.

---

# Table of Contents

- [Variables](#variables)
- [Conditions](#conditions)
- [Files and Directories](#files-and-directories)
- [Strings](#strings)
- [Operators](#operators)
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