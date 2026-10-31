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

Before adding something, check all of these. If one fails, don't add it and tell the user which rule it breaks. If they asked for several packages, still handle the others.

- It is a tool for Dev & Ops work, or for work chat (like Telegram or WhatsApp). Not a personal app: no music, games, or personal finance apps (like Trezor Suite).
- It is a plain CLI tool, not a full-screen terminal app with its own layout (like lazygit, k9s, or lazydocker).
- It runs on macOS 15 or newer, on Apple Silicon. For an app, run `brew info --cask NAME`: its "Requirements" part may list a macOS version, but not an architecture (arm64 or x86_64).
- It is not a programming language or runtime (Node, Python, Go, Java, ...). Those are installed per project with `mise`.
- It is not already in the list, under another name. For example, `kubectl` is `brew "kubernetes-cli"`.

## Add a package

1. Find the exact name:
   - CLI tool: `brew search NAME`, then `brew info --formula NAME`
   - App: `brew search --cask NAME`, then `brew info --cask NAME`
   - App Store app: the id is the number in the App Store link (`apps.apple.com/app/id123`)

   Prefer `brew` or `cask` over `mas`. Use `mas` only when the app is not in Homebrew.

2. Add one line to `Brewfile`, at the end of the right section (or next to a closely related tool, like `docker-buildx` after `docker`):

   ```ruby
   brew "name"               # Short description, starts with a capital letter
   cask "name"               # Short description
   mas "Name", id: 123       # Short description
   ```

   - Line the `#` comments up with the lines around them.
   - The comment says what the tool does, in a few simple words. No brand words like "blazing fast".
   - If no section fits, add a new one with the same `# ---` header style as the others.

3. Add the same package to the matching table in `README.md`:
   - Link the name to its official website (or download page for apps, `apps.apple.com` page for App Store apps). If the tool has no website, link its GitHub repo.
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

If you added a README link, check that it opens:

```bash
curl -sSIL -o /dev/null -w '%{http_code}\n' URL   # 200 is good
```

Some sites block scripts or answer slowly: 403, 429 or a timeout is fine (the GitHub check allows them too). A 404 is not.

If you changed a script, also run:

```bash
shellcheck install.sh scripts/*.sh
```

If `brew` is not installed (for example, on Linux or in a cloud sandbox), you cannot run the validator. Say so to the user. GitHub Actions runs all these checks on the pull request.

Do not run `brew bundle install` unless the user asks. It installs software on their Mac.

Do not commit unless the user asks. When they do, use a short message like `Add k9s` or `Remove warp`.

## Don't

- Don't run `brew bundle dump`. It rewrites the `Brewfile` and removes the sections and comments.
- Don't add version pins or `Brewfile.lock.json` (it is in `.gitignore`).
- Don't add options like `args:` or `restart_service:` unless they are really needed.
- Don't change `install.sh` to add a package. The `Brewfile` is the only list.
