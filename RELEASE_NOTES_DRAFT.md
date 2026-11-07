# brework v1.5.5 (draft)

Fixes from a release review. The list of tools and apps is the same (53 formulae and 20 casks in the `Brewfile`, 55 entries with `--cli-only`).

To update, run the [install command](README.md#install) again.

## Fixed

- **Homebrew is added to your `PATH` on a Mac moved over from an Intel Mac.** When a shell file already had a line for the Intel Homebrew (`/usr/local/bin/brew shellenv`, for example after Migration Assistant), `install.sh` did not add the Apple Silicon line, so login shells put `/usr/bin` first. Run the install command again to add it.
- **The smoke test says when a test port is in use.** The `httpie`/`wget` check (port 8765) and the `redis-cli` check (port 8766) now report a busy port, with the `lsof` command to see what uses it. `redis-cli` is only tested against the server the smoke test started.

## Changed

- `install.sh` checks for macOS 15 or newer, an admin account and enough free disk at the start, instead of failing later in the install. End-to-end CI also tests macOS 15.
- `install.sh` explains what to do when the Homebrew installer fails.
- `install.sh --help` and `scripts/smoke-test.sh --help` show the options (`-h` works too).
- Docs: how to install a tagged release, a warning that `brew bundle cleanup` uninstalls everything it lists when you press `y`, a step in "Remove brework" for the `docker compose` and `docker buildx` links, and what to use instead of `~/.brework` when you installed from a downloaded copy.
- The bug report form asks for `git -C ~/.brework describe --tags --always`.
- New [CHANGELOG.md](CHANGELOG.md) with every release since v1.0.0.
- CI: actionlint checks the workflows, the link check action is pinned to a commit, and the Brewfile check stops after 20 minutes. The pull request template asks for a green End-to-end check.

## How this release was tested

Run locally on macOS (Apple Silicon):

- `shellcheck install.sh scripts/*.sh` (ShellCheck 0.11.0), `bash -n` on every script, `ruby -c Brewfile Brewfile.apps`, `actionlint`: no findings.
- `install.sh --help`, `-h` and `curl ... | bash -s -- --help` exit 0; unknown or extra options exit 1 before changing anything. Same for `scripts/smoke-test.sh`.
- The PATH line logic, the macOS version check and the smoke test's busy-port handling were tested in isolation (pulled out of the scripts).
- `gitleaks` and `trivy` (secrets, misconfiguration): nothing found.

Not yet tested for this release: a full `install.sh` run and `scripts/smoke-test.sh` on a Mac, the `scripts/validate-brewfile.sh` list check, and the new CI steps on GitHub. The End-to-end and Validate workflows cover these on GitHub.
