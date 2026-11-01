# Contributing

Thanks for helping. brework is one person's list of tools for Dev & Ops work on a Mac. It stays small and simple on purpose.

## Suggest a tool or an app

Open an issue with the [Suggest a tool](https://github.com/sgnd/brework/issues/new?template=suggest-a-tool.yml) form. A tool fits when all of these are true:

- It is for Dev & Ops work, or for work chat. Not a personal app (music, games, personal finance).
- It is a plain CLI tool, not a full-screen terminal app (like lazygit or k9s).
- It runs on macOS 15 or newer, on Apple Silicon.
- It is not a programming language or runtime. Those are installed per project with `mise`.
- It is not already in the list under another name.

Want your own list? [Fork the repo](README.md#make-it-yours). That is what it is made for.

## Report a bug

Open an issue with the [Bug report](https://github.com/sgnd/brework/issues/new?template=bug-report.yml) form. For a security problem, see [SECURITY.md](SECURITY.md) instead.

## Send a pull request

1. Add or remove a package as the [README](README.md#change-the-list) shows. Keep the `Brewfile`, `Brewfile.apps` and the README tables the same.
2. Run the checks:

   ```bash
   scripts/validate-brewfile.sh        # the last line must say: 0 missing
   shellcheck install.sh scripts/*.sh  # if you changed a script
   ```

3. Open the pull request. GitHub runs the same checks. When you change a Brewfile, `install.sh` or `smoke-test.sh`, it also runs `install.sh` on a real Mac. That takes about 20 minutes.

## How GitHub checks the list

[GitHub Actions](.github/workflows/validate.yml) runs `scripts/validate-brewfile.sh` on every push to `main`, every pull request and every Monday. It also checks that the macOS versions in the README [Requirements](README.md#requirements) still match the App Store, the shell scripts, and the links in the README. [Dependabot](.github/dependabot.yml) opens a pull request when a GitHub Action has a new version.

When a pull request changes a Brewfile, `install.sh` or `smoke-test.sh`, [another check](.github/workflows/e2e.yml) removes Homebrew from a GitHub Mac and then runs `install.sh` for real, once with everything and once with `--cli-only`, and then runs `smoke-test.sh`. Some things are left out, because GitHub's Macs cannot do them: App Store apps (no Apple ID), starting Docker (Colima cannot start a VM there) and typing a password. The test also starts with this repo already in `~/.brework`, so it does not test the first download of the repo.

## Writing

Keep the words simple and the lines short, like the rest of the repo. The README is for newcomers too: explain a new word in [Words used here](README.md#words-used-here), and put technical details in [How it works](README.md#how-it-works).

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
