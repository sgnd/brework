---
name: brework-maintain
description: Add, remove, rename, or move a tool or app in the brework Brewfile or Brewfile.apps, and keep the README tables in sync. Use when someone asks to add or remove a package, or edits a Brewfile or the "What's inside" tables in README.md.
---

# Maintain the brework Brewfiles

brework keeps its package list in these places, and they must match:

- `Brewfile`: the CLI tools. Its last line loads `Brewfile.apps`.
- `Brewfile.apps`: the GUI and App Store apps. `install.sh --cli-only` skips this file.
- `MISE_TOOLS` in `install.sh`: the few tools that come from `mise` instead (like `usql` and `mongosh`)
- `README.md`, section "What's inside": the same lists, as tables with links (one table per file)

Keep it simple. Short lines, simple English, no new scripts or tools. The README is for newcomers: explain a new word in "Words used here", and put technical details in `docs/advanced.md`.

## Should it be in the list?

Before adding something, check all of these. If one fails, don't add it and tell the user which rule it breaks. If they asked for several packages, still handle the others.

- It is a tool for Dev & Ops work, or for work chat (like Telegram or WhatsApp). Not a personal app: no music, games, or personal finance apps (like Trezor Suite).
- It is a plain CLI tool or an app, not a full-screen terminal app with its own layout (like lazygit, k9s, or lazydocker).
- It runs on macOS 15 or newer, on Apple Silicon. For an app, run `brew info --cask NAME` and read its "Requirements" part. If it says `x86_64 architecture`, the app is Intel only: don't add it.
- It is not a programming language or runtime (Node, Python, Go, Java, ...). Those are installed per project with `mise`.
- It is not already in the list, under another name. For example, `kubectl` is `brew "kubernetes-cli"`.

## Add a package

1. Find the exact name:
   - CLI tool: `brew search NAME`, then `brew info --formula NAME`
   - App: `brew search --cask NAME`, then `brew info --cask NAME`
   - App Store app: the id is the number in the App Store link (`apps.apple.com/app/id123`)

   Prefer `brew` or `cask` over `mas`. Use `mas` when the app is not in Homebrew, or when the user wants the App Store version. Don't move an existing `mas` app to a cask.

   Don't add other taps (Homebrew makes you trust them, and they often build from source). A tool that is not in Homebrew core, or that would pull in a language runtime (like `mongosh` with Node.js), can come from `mise` instead: `mise registry | grep NAME`. Add `NAME@VERSION` to `MISE_TOOLS` in `install.sh`. The validator and the "command is found" check read that line by themselves. Add a smoke test check (with `mise exec --`) and the README row, like `usql` and `mongosh`. Also update the places that name the mise tools: "How it works" and `mise unuse` in "Remove brework" (`docs/advanced.md`), and the mise comment in the Brewfile.

2. Add one line to `Brewfile` (a CLI tool, or something the terminal needs, like a font) or `Brewfile.apps` (an app with a window, or an App Store app), at the end of the right section (or next to a closely related tool, like `docker-buildx` after `docker`):

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
   - Keep the order the same as in the Brewfile.
   - A new Brewfile section needs a new table row. In the CLI table, fill in "Used for" too: what the tools in that row help you do, in a few simple words.

4. Check it (see "Check your change" below).

## Remove a package

1. Delete its line from `Brewfile` or `Brewfile.apps` (or its `NAME@VERSION` from `MISE_TOOLS` in `install.sh`).
2. Delete it from the `README.md` table. If the row is now empty, delete the row, and the Brewfile section header too.
3. Do not uninstall it from the Mac. Deleting the line does not uninstall it, and the user may still want it. Tell them how to uninstall it instead: `brew uninstall NAME` (a CLI tool), `brew uninstall --cask NAME` (an app), `mise unuse --global NAME` (a mise tool), or drag it from `/Applications` to the Trash (an App Store app).
4. Search the whole repo for the name, the skills included, and update every place that still names it (for example "After you install", "Troubleshooting", the smoke test, or a sign-in command):

   ```bash
   git grep -n -i NAME
   ```

## A package was removed or renamed

When Homebrew renames a package, the old name keeps working. You can still change it to the new name: `brew info OLD-NAME` shows the new one.

When Homebrew removes or disables a package, the weekly GitHub check fails with `MISSING  name (removed or disabled)`.

1. Run `brew info NAME` to see why. Look for a replacement with `brew search`.
2. Change or delete the line in the Brewfile, and update `README.md` the same way.

When an App Store app needs a newer macOS, the check fails with `MISSING  macOS 27.0 in README.md (Xcode needs it now ...)`. Put the new version in `README.md` Troubleshooting ("Xcode did not install", or a new entry for another app), and remove the old version there.

## Check your change

Run:

```bash
scripts/validate-brewfile.sh
```

The last line must say `0 missing`. A `NEWER` line is only a hint that a mise tool has a newer version: tell the user, and change `MISE_TOOLS` only if they ask.

If you added a README link, check that it opens:

```bash
curl -sSIL -o /dev/null -w '%{http_code}\n' URL   # 200 is good
```

Some sites block scripts or answer slowly: 403, 429 or a timeout is fine (the GitHub check allows them too). A 404 is not.

After installing, check that the tools really work (it also checks that every command is found in a new terminal, and in the shells that IDEs, AI agents and scripts use):

```bash
scripts/smoke-test.sh
```

If a new CLI tool can do a small job offline, add a check for it in `scripts/smoke-test.sh`, like the other checks there.

If you changed a script, also run:

```bash
shellcheck install.sh scripts/*.sh
```

If `brew` is not installed (for example, on Linux or in a cloud sandbox), you cannot run the validator. Say so to the user. GitHub Actions runs all these checks on the pull request.

Do not run `brew bundle install` unless the user asks. It installs software on their Mac.

If the Mac was set up with `--cli-only` (then `command -v mas` prints nothing, because `mas` comes from `Brewfile.apps`), plain `brew bundle install` installs every skipped app. Use `HOMEBREW_BREWORK_CLI_ONLY=1 brew bundle install` and `scripts/smoke-test.sh --cli-only` instead. To install only the new package, `brew install NAME` (or `brew install --cask NAME`) is enough.

Do not commit unless the user asks. When they do, use a short message like `Add k9s` or `Remove warp`.

## Don't

- Don't run `brew bundle dump`. It makes a new file without the sections and comments.
- Don't add version pins or `Brewfile.lock.json` (it is in `.gitignore`).
- Don't add options like `args:` or `restart_service:` unless they are really needed.
- Don't change `install.sh` to add a package, except the `MISE_TOOLS` line (see "Add a package", step 1).
- Don't remove the last line of `Brewfile` (it loads `Brewfile.apps`).
