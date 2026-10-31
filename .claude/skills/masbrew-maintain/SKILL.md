---
name: masbrew-maintain
description: Add, remove, rename, or move a tool or app in the masbrew Brewfile, and keep the README tables in sync. Use when someone asks to add or remove a package, or edits the Brewfile or the "What's inside" tables in README.md.
---

# Maintain the masbrew Brewfile

masbrew keeps its package list in two places that must match:

- `Brewfile`: what gets installed
- `README.md`, section "What's inside": the same list, as tables with links

Keep it simple. Short lines, simple English, no new scripts or tools.

## Should it be in the list?

Before adding something, check all of these. If one fails, tell the user and stop.

- It is a tool for Dev & Ops work. Not a personal or hobby app.
- It runs on macOS, on both Apple Silicon and Intel.
- It is not a programming language or runtime (Node, Python, Go, Java, ...). Those are installed per project with `mise`.
- It is not already in the list, under another name. For example, `kubectl` is `brew "kubernetes-cli"`.

## Add a package

1. Find the exact name:
   - CLI tool: `brew search NAME`, then `brew info --formula NAME`
   - App: `brew search --cask NAME`, then `brew info --cask NAME`
   - App Store app: the id is the number in the App Store link (`apps.apple.com/app/id123`)

   Prefer `brew` or `cask` over `mas`. Use `mas` only when the app is not in Homebrew.

2. Add one line to `Brewfile`, in the right section, at a sensible spot in that section:

   ```ruby
   brew "name"               # Short description, starts with a capital letter
   cask "name"               # Short description
   mas "Name", id: 123       # Short description
   ```

   - Line the `#` comments up with the lines around them.
   - The comment says what the tool does, in a few simple words. No brand words like "blazing fast".
   - If no section fits, add a new one with the same `# ---` header style as the others.

3. Add the same package to the matching table in `README.md`:
   - Link the name to its official website (or download page for apps, `apps.apple.com` page for App Store apps).
   - Use the name people type or know (`kubectl`, not `kubernetes-cli`).
   - Keep the order the same as in the `Brewfile`.
   - A new `Brewfile` section needs a new table row.

4. Check it (see "Check your change" below).

## Remove a package

1. Delete its line from `Brewfile`.
2. Delete it from the `README.md` table. If the row is now empty, delete the row, and the `Brewfile` section header too.
3. Do not uninstall it from the Mac. Deleting the line does not uninstall it, and the user may still want it. Tell them the uninstall command instead (`brew uninstall NAME` or `brew uninstall --cask NAME`).
4. Search the rest of `README.md` and `install.sh` for the name, for example in "After you install" or "Troubleshooting", and update those parts.

## Rename a package

Homebrew sometimes renames packages. The weekly GitHub check then fails with `MISSING  name`.

1. Find the new name: `brew info NAME` often says where it moved. Otherwise search with `brew search`.
2. Change the line in `Brewfile`. Change the `README.md` link only if the website changed.

## Check your change

Run:

```bash
scripts/validate-brewfile.sh
```

Every line must say `ok`, and the last line must say `0 missing`.

If you changed a script, also run:

```bash
shellcheck install.sh scripts/*.sh
```

Do not run `brew bundle install` unless the user asks. It installs software on their Mac.

## Don't

- Don't run `brew bundle dump`. It rewrites the `Brewfile` and removes the sections and comments.
- Don't add version pins or `Brewfile.lock.json` (it is in `.gitignore`).
- Don't add options like `args:` or `restart_service:` unless they are really needed.
- Don't change `install.sh` to add a package. The `Brewfile` is the only list.
