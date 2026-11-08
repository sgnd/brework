# Contributing

Thanks for helping. brework is one person's list of tools for Dev & Ops work on a Mac. It stays small and simple on purpose.

## Suggest a tool or an app

Open an issue with the [Suggest a tool](https://github.com/sgnd/brework/issues/new?template=suggest-a-tool.yml) form. A tool fits when all of these are true:

- It is for Dev & Ops work, or for work chat. Not a personal app (music, games, personal finance).
- It is a plain CLI tool or an app, not a full-screen terminal app (like lazygit or k9s).
- It runs on macOS 15 or newer, on Apple Silicon.
- It is not a programming language or runtime. Those are installed per project with `mise`.
- It is not already in the list under another name.

Want your own list? [Fork the repo](docs/advanced.md#make-it-yours). That is what it is made for.

## Report a bug

Open an issue with the [Bug report](https://github.com/sgnd/brework/issues/new?template=bug-report.yml) form. For a security problem, see [SECURITY.md](SECURITY.md) instead.

## Send a pull request

1. Add or remove a package as [docs/advanced.md](docs/advanced.md#change-the-list) shows. Keep the `Brewfile`, `Brewfile.apps` and the README tables the same.
2. Run the checks:

   ```bash
   scripts/validate-brewfile.sh        # the last line must say: 0 missing
   shellcheck install.sh scripts/*.sh  # if you changed a script
   actionlint                          # if you changed a workflow in .github/workflows
   ```

   The first one runs `brew update`, and installs `mise` if you don't have it yet.

3. Open the pull request. GitHub runs the same checks. See [How GitHub checks the list](#how-github-checks-the-list).
4. If your change is something users notice, add a line under `Unreleased` in [CHANGELOG.md](CHANGELOG.md).

## How GitHub checks the list

[GitHub Actions](.github/workflows/validate.yml) runs `scripts/validate-brewfile.sh` on every push to `main`, every pull request, every release tag and every Monday. It checks the remote desktop apps too, although `install.sh` only installs them with `--remote-desktop`. It also checks that the README names the macOS version each App Store app needs (in [Troubleshooting](README.md#troubleshooting)), the shell scripts, the workflows (with actionlint), and the links (and `#section` links) in the README, docs/advanced.md, this file and SECURITY.md. The "Release version" check makes sure every install command in the docs names the version in `install.sh` (`BREWORK_VERSION`), and that a release tag is that version. [Dependabot](.github/dependabot.yml) opens a pull request when a GitHub Action has a new version.

When a pull request changes a Brewfile, `install.sh` or `smoke-test.sh`, and every Monday, [another check](.github/workflows/e2e.yml) removes Homebrew from a GitHub Mac and then runs `install.sh` for real on macOS 15 (the oldest supported), 26 and 27, each once with everything and once with `--cli-only` (twice per run, to check that a second run changes nothing), and then runs `smoke-test.sh`. Some things are left out, because GitHub's Macs cannot do them: App Store apps (no Apple ID), starting Docker (Colima cannot start a VM there) and typing a password. The remote desktop apps (`--remote-desktop`) are not installed there either. The test also starts with this repo already in `~/.brework`, tagged with the version in `BREWORK_VERSION`, so it tests the release check and the move to the tag, but not the first download of the repo.

The Macs only run when one of those files changes. The "End-to-end result" check runs on every pull request and is required: it is green when the Macs passed, or when none of those files changed.

## Make a release

For the maintainer. The install command installs one release: the tag named in `install.sh` (`BREWORK_VERSION`) and in the command's address. `install.sh` refuses a tag whose `install.sh` names another version, and a tag that changed after a Mac got it. So a release needs these steps, in this order:

1. Pick the new version, like `v1.7.0`.
2. In a pull request:
   - Set `BREWORK_VERSION="v1.7.0"` in `install.sh`.
   - Put the new version in every install command. This lists them: `git grep -nE '(sgnd/brework/|--branch )v[0-9]' -- ':!CHANGELOG.md'` (`install.sh`, the README, `docs/advanced.md` and the `brework-setup` skill). The "Release version" check fails if one is left.
   - In [CHANGELOG.md](CHANGELOG.md), rename `Unreleased` to the version and date, and start a new, empty `Unreleased`.
3. Merge it, then tag that merge commit right away. Until the tag exists, the install command in the README fails.

   ```bash
   git switch main && git pull --ff-only
   git tag -a v1.7.0 -m "brework v1.7.0"
   git push origin v1.7.0
   ```

   The Validate workflow runs on the tag. Its "Release version" check must be green.
4. Make the release on GitHub ([Releases](https://github.com/sgnd/brework/releases) > Draft a new release) from the tag, with the notes: what changed, and how it was tested.

Never move or delete a tag after you push it. Macs that already have it refuse the changed tag, and people can no longer see what they installed. Fix a bad release with a new version.

Once, in the repo settings on GitHub: Settings > Rules > Rulesets > New tag ruleset, for the tags `v*`, with "Restrict updates" and "Restrict deletions" turned on. Then nobody can move or delete a release tag by mistake.

## Writing

Keep the words simple and the lines short, like the rest of the repo. The README is for newcomers too: explain a new word in [Words used here](README.md#words-used-here), and put technical details in [docs/advanced.md](docs/advanced.md). Keep the README short: it is for people who just want to install.

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
