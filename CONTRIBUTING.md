# Contributing

Thanks for helping. masbrew is one person's list of tools for Dev & Ops work on a Mac. It stays small and simple on purpose.

## Suggest a tool or an app

Open an issue with the [Suggest a tool](https://github.com/sgnd/masbrew/issues/new?template=suggest-a-tool.yml) form. A tool fits when all of these are true:

- It is for Dev & Ops work, or for work chat. Not a personal app (music, games, personal finance).
- It is a plain CLI tool, not a full-screen terminal app (like lazygit or k9s).
- It runs on macOS 15 or newer, on Apple Silicon.
- It is not a programming language or runtime. Those are installed per project with `mise`.
- It is not already in the list under another name.

Want your own list? [Fork the repo](README.md#make-it-yours). That is what it is made for.

## Report a bug

Open an issue with the [Bug report](https://github.com/sgnd/masbrew/issues/new?template=bug-report.yml) form. For a security problem, see [SECURITY.md](SECURITY.md) instead.

## Send a pull request

1. Add or remove a package as the [README](README.md#change-the-list) shows. Keep the `Brewfile`, `Brewfile.apps` and the README tables the same.
2. Run the checks:

   ```bash
   scripts/validate-brewfile.sh        # the last line must say: 0 missing
   shellcheck install.sh scripts/*.sh  # if you changed a script
   ```

3. Open the pull request. GitHub runs the same checks. When you change a Brewfile, `install.sh` or `smoke-test.sh`, it also runs `install.sh` on a real Mac. That takes about 20 minutes.

Keep the words simple and the lines short, like the rest of the repo.

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
