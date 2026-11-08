# Changelog

What changed in each release. The [GitHub releases](https://github.com/sgnd/brework/releases) have the full notes, with how each release was tested.

To update, run the [install command](README.md#install) of the newest release, unless a release says otherwise. Up to v1.5.4, the install command always installed `main`.

## Unreleased

### Security

- **The install command installs one release, not `main`.** The command names its version (`.../sgnd/brework/v1.6.0/install.sh`), and `install.sh` downloads exactly that release to `~/.brework` after it checks it: the downloaded `install.sh` must name the same version, and a release your Mac already has must not have changed on GitHub. Before, every run installed whatever was on `main` at that moment. Running the same command again keeps the same list: to update, run the newest release's command (the README shows it). A `~/.brework` from an older install moves from `main` to the release. To install `main` anyway, set `BREWORK_REF=main` (see [Which version you get](docs/advanced.md#which-version-you-get)).
- **`install.sh` stops when `~/.brework` has changes or commits of yours,** instead of running a changed list or saying only "Could not update". Nothing from the list is installed then.
- **Keep the `brework-setup` agent skill a copy, not a link to `~/.brework`.** With a link, the instructions your AI agent follows changed every time `~/.brework` changed. Made the link? Replace it with a copy: `rm ~/.claude/skills/brework-setup && cp -R ~/.brework/.claude/skills/brework-setup ~/.claude/skills/brework-setup`.
- **TeamViewer and AnyDesk are no longer installed by default.** They let someone else control your Mac, TeamViewer runs a background service with full admin rights (root), and Homebrew does not check the AnyDesk download against a fixed checksum. Add `--remote-desktop` to the install command to get them. Already installed? They stay. To remove them: `brew uninstall --cask teamviewer anydesk`.

### Fixed

- **A commented-out Homebrew line no longer stops `install.sh`** from adding the real one: lines that start with `#` in your shell files are ignored when it checks what is already there.
- **Homebrew is added to your `PATH` on a Mac moved over from an Intel Mac.** When a shell file already had a line for the Intel Homebrew (`/usr/local/bin/brew shellenv`, for example after Migration Assistant), `install.sh` did not add the Apple Silicon line, so login shells put `/usr/bin` first. Run the install command again to add it.
- **The smoke test says when a test port is in use.** The `httpie`/`wget` and `redis-cli` checks start a small local server on port 8765 or 8766. When that port is taken, the check now says so, with the `lsof` command to see what uses it. `redis-cli` is only tested against its own server.

### Changed

- **CI:** a "Release version" check: every install command in the docs names the version in `install.sh` (`BREWORK_VERSION`), and a pushed tag must be that version. The end-to-end test installs the pull request through the same release check, and checks that TeamViewer and AnyDesk are not installed by default.
- **CI:** the "End-to-end result" check runs on every pull request and is required. It passes when the install on the Macs passed, or when the pull request does not change a Brewfile, `install.sh`, `smoke-test.sh` or `e2e.yml`.
- **`install.sh` checks for macOS 15 or newer, an admin account and enough free disk** at the start, instead of failing later in the install. End-to-end CI also tests macOS 15.
- **`install.sh` explains what to do when the Homebrew installer fails.**
- **`install.sh --help` and `scripts/smoke-test.sh --help`** show the options (`-h` works too).
- **Docs:** how to install a tagged release, a warning that `brew bundle cleanup` uninstalls everything it lists when you press `y`, a step in "Remove brework" for the `docker compose` and `docker buildx` links, and what to use instead of `~/.brework` when you installed from a downloaded copy.
- **The bug report form** asks for `git -C ~/.brework describe --tags --always`.
- **CI:** actionlint checks the workflows, the link check action is pinned to a commit, and the Brewfile check stops after 20 minutes. The pull request template asks for a green End-to-end check.

## v1.5.4 (2026-11-07)

- The list check (`scripts/validate-brewfile.sh`) no longer stops early when the App Store lookup or `mise latest` fails for a moment, and no longer reports a mise version as missing when it exists.
- The README check looks for `macOS <version>`, not just the number.
- The smoke test works when `USER` or `LOGNAME` is not set (cron, launchd, sudo), and reads App Store ids the same way as the list check.
- `install.sh` keeps your `~/.bash_login` when it makes a new `~/.bash_profile`, and checks more reliably whether Colima already starts at login.

## v1.5.3 (2026-11-07)

- The bug report form asks for your brework version.
- The end-to-end test also runs on macOS 27.

## v1.5.2 (2026-11-04)

Fixes from a full review. The list of tools is the same.

- The smoke test no longer fails when an update is waiting (`brew bundle check --no-upgrade --verbose`).
- `install.sh` no longer glues its line to the last line of a shell file without a final new line.
- The README had the iPhone macOS version for WhatsApp. Only Xcode needs a newer macOS.
- "Docker is not running (yet)" instead of a Docker Hub error.
- The smoke test always uses the local Docker (Colima), and the Kubernetes checks use an empty test config.

## v1.5.1 (2026-11-02)

- `install.sh` shows `Step N of 7` headers, a clear ending with the check command, and a short list of what did not install.
- New "Remove brework" section in `docs/advanced.md`.

## v1.5.0 (2026-11-02)

- Added the Google Cloud CLI (`gcloud`, `gsutil`, `bq`).
- A shorter README for newcomers. The details moved to `docs/advanced.md`.

## v1.4.1 (2026-11-02)

- `install.sh` adds the Homebrew and mise lines to `~/.zshenv`, `~/.zprofile` and `~/.bash_profile`, so every shell (`zsh -c`, `zsh -l -c`, `bash -l -c`) finds the same tools. The smoke test checks all four shells.

## v1.4.0 (2026-11-02)

- `install.sh` adds the mise tools to `~/.zprofile`, so IDEs, scripts and AI agents find them.

## v1.3.2 (2026-11-01)

- The `brework-setup` skill can be a link to `~/.brework`, so it stays current.
- The weekly check warns when a mise tool has a newer version. The Docker checks retry `docker pull`.

## v1.3.1 (2026-11-01)

- `mongosh` comes from mise (`MISE_TOOLS` in `install.sh`), so Homebrew no longer installs a second Node.js. Upgrading: `brew uninstall mongosh && brew autoremove`.

## v1.3.0 (2026-11-01)

- 12 new CLI tools: git-lfs, shfmt, actionlint, crane, kubeconform, usql, mongosh, redis-cli, k6, hyperfine, just and doggo. `usql` comes from mise.

## v1.2.0 (2026-11-01)

- masbrew is now **brework**. The repo lives in `~/.brework`, and the CLI-only variable is `HOMEBREW_BREWORK_CLI_ONLY=1`.
- Added UTM.

## v1.1.1 (2026-11-01)

- The list check fails when an App Store app needs a newer macOS than the README says.
- Dependabot, CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md, issue forms and a pull request template.

## v1.1.0 (2026-11-01)

- `--cli-only` installs only the CLI tools (`Brewfile`), without `Brewfile.apps`.
- `install.sh` turns on mise, direnv, zoxide and fzf, sets delta as the git pager, and starts Colima at login.
- New smoke test that checks every tool really works.

## v1.0.0 (2026-10-31)

- First stable release: one command sets up an Apple Silicon Mac with CLI tools, apps and Mac App Store apps.
