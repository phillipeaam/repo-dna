# Windows and Git Bash support

Windows 10/11 with Git Bash and Bash 4.3+ is an explicitly supported RepoDNA
1.0 environment. Python 3.11+ may be exposed as `python3`, `python`, or the
Windows Python Launcher `py`.

Run RepoDNA from the repository:

```bash
cd "/c/Users/Phillipe Augusto/Development/my-project"
bash /e/repo-dna/dna-analysis.sh
```

Or pass the repository explicitly:

```bash
bash /e/repo-dna/dna-analysis.sh "/c/Users/Phillipe Augusto/Development/my-project"
bash /e/repo-dna/dna-analysis.sh --repository "C:\Users\Phillipe Augusto\Development\my-project"
```

There must be whitespace between the script name and repository argument. For
example, `./dna-analysis.sh"/c/..."` is invalid shell syntax.

The Windows compatibility contract covers spaces, accented names, `/` and `\`
input separators, CRLF source content, paths longer than 260 characters, ZIP,
missing optional Unix commands, Git Bash, PowerShell launching Git Bash, and
repositories located outside `C:`. The CI runs portable smoke tests on Windows,
Linux, and macOS; the Windows job uses the Git for Windows Bash executable.

For very long tracked paths, Git for Windows may also require:

```bash
git config core.longpaths true
```

RepoDNA normalizes paths in JSON and reports to repository-relative `/`
separators regardless of the input form.
