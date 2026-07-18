# Installation and updates

RepoDNA can run directly from a local checkout:

```bash
git clone https://github.com/phillipeaam/repo-dna.git
cd repo-dna
./repodna analyze .
```

To install the `repodna` command for the current user, run:

```bash
./install.sh
repodna doctor
repodna --version
```

The installer copies the runtime to `${XDG_DATA_HOME:-$HOME/.local/share}/repodna`
and creates the command at `${XDG_BIN_HOME:-$HOME/.local/bin}/repodna`. It does
not require administrator privileges and does not install Python packages.

On Windows/Git Bash, `$HOME` normally represents the Windows user profile. The
default launcher is therefore created at a path equivalent to:

```text
C:\Users\Your Name\.local\bin\repodna
```

If `~/.local/bin` is not already in `PATH`, add this to `~/.bashrc` and restart
Git Bash:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

The locations can be overridden for managed or portable installations:

```bash
REPODNA_INSTALL_DIR=/opt/repodna \
REPODNA_BIN_DIR="$HOME/bin" \
./install.sh
```

## Updating

Update the checkout and run the same installer again. Existing installed
runtime files are replaced, while repository analysis data and user
configuration are not touched:

```bash
cd /path/to/repo-dna
git pull --ff-only
./install.sh
repodna --version
```

The root [`VERSION`](../VERSION) file is the single source used by the CLI,
installer, tests, and release process.
