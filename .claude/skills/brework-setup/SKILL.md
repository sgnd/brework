---
name: brework-setup
description: Set up a Mac with brework (install.sh), then check that every tool really works. Use when someone asks to install brework, set up or reinstall their Mac with it, run install.sh, or fix a failed brework install.
---

# Set up a Mac with brework

The goal: after one command, the Mac is ready for Dev & Ops work. Every tool in the list is installed, works, and is found when you type it in a new terminal.

Keep it simple. Use the repo's own scripts. Don't install extra tools.

## 1. Check the Mac first

Run these and stop if one fails. Tell the user why, in plain words.

```bash
sysctl -n hw.optional.arm64        # must print 1: Apple Silicon (M1 or newer)
sysctl -n sysctl.proc_translated   # must print 0 (or nothing): not a Rosetta terminal
sw_vers -productVersion            # must be 15 or newer
```

- **Intel Mac (prints 0 or nothing):** stop. The Homebrew installer no longer works on Intel Macs, so brework cannot set one up. Don't try other ways to install Homebrew. Tell the user, and point to the "Intel Macs" part of the README.
- **Rosetta terminal (prints 1):** ask the user to turn off "Open using Rosetta" for their terminal app, then open a new terminal.
- **macOS older than 15:** ask the user to update macOS first.
- **Some App Store apps need a newer macOS.** Look up the oldest macOS that Xcode accepts:

  ```bash
  curl -s 'https://itunes.apple.com/lookup?id=497799835' | jq -r '.results[0].minimumOsVersion'
  ```

  If the Mac is older, everything installs except Xcode. Tell the user before you start. (WhatsApp needs 15.1.)

Also check the free space with `df -h /`: about 40 GB for everything, about 20 GB with `--cli-only`.

## 2. Ask the user two things

- **Everything, or only the CLI tools?** Only the CLI tools means `--cli-only`: no GUI apps, no App Store apps, and no App Store sign-in.
- **For everything:** are they signed in to the Mac App Store? If not, ask them to open the App Store and sign in first.

## 3. Run the installer

The installer asks for the user's password (sudo) several times. Some apps use a `.pkg` installer, and the App Store apps need it too. You cannot type it. So run the installer where the user can see it and type: in their terminal, or in a terminal tab they can open. Tell them to watch for `Password:`.

```bash
curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash                   # everything
curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash -s -- --cli-only  # CLI tools only
```

If the repo is already on the Mac (for example in `~/.brework`), you can run `./install.sh` from that folder instead.

Most tools come from Homebrew. A few come from `mise`, at fixed versions (`MISE_TOOLS` in `install.sh`, like `usql` and `mongosh`). `mise use --global` adds them to `~/.config/mise/config.toml`. The installer also adds lines to `~/.zshrc`, `~/.zshenv`, `~/.zprofile` and `~/.bash_profile` (each ends with `# added by brework`), so every shell finds the tools. Tell the user about these files, because they are theirs.

A first install takes a long time: often 30 to 60 minutes, more on a slow connection. A quiet terminal is usually a download in progress, not a hang. Check with `ps -ax | grep curl` before you call it stuck.

The script ends with `Done!`, or with `Error: Some packages did not install`.

## 4. If something did not install

Read the errors above the last line. Common ones:

| Error | What to do |
| --- | --- |
| `Download failed` / `curl: (56)` / `unexpected eof` | The connection dropped. Run the installer again. Homebrew keeps the part it already downloaded and continues. For one big app, `brew fetch --cask NAME` a few times also works. |
| `It seems there is already an App` | The app was installed without Homebrew. Ask the user, then run `brew install --cask --adopt NAME` (it asks for the password). |
| An App Store app did not install | The user is not signed in to the App Store. Ask them to sign in, then run the installer again. |
| Xcode did not install | macOS is older than Xcode needs. Tell the user: update macOS, or skip Xcode. |
| `This terminal runs in Rosetta` | See step 1. |
| `mise` fails on `usql` or `mongosh` (for example `rate limit` or a timeout) | mise downloads them from GitHub. Wait a bit and run the installer again, or run `mise use --global` with the tools from `MISE_TOOLS` in `install.sh`. |

Run the installer again after each fix. It installs what is missing and leaves the rest alone.

Never delete user data or apps to make an install pass. Ask first.

## 5. Check that everything works

Ask the user to open a **new** terminal window. The new tools and shell settings only load there. Then run:

```bash
~/.brework/scripts/smoke-test.sh              # add --cli-only if they installed only the CLI tools
```

(If the repo is somewhere else, run `scripts/smoke-test.sh` from that folder.)

It checks three things:

- Every command from the list is found in a new terminal, and in the shells that don't read `~/.zshrc`: IDEs and AI agents (`zsh -l -c`), scripts and ssh (`zsh -c`), and bash.
- Every CLI tool does one small real task.
- Every app that Homebrew puts in /Applications is signed and runs on Apple Silicon.

The last line must say `0 failed`.

For each `FAIL`, read the lines under it:

- `command not found: NAME`: the command is not linked. For a cask (an app), `brew reinstall --cask THE-CASK` makes the links again. It closes the app, so ask the user first. For a CLI tool, `brew link NAME`. For a tool from `MISE_TOOLS` (like `usql`), check that `mise activate` is in `~/.zshrc`, then run `mise use --global` with it.
- Only in the checks for the shells that don't read `~/.zshrc` (`command not found: NAME`, or `not the one from mise: PATH`, like the macOS `/usr/bin/java`): `~/.zshenv`, `~/.zprofile` or `~/.bash_profile` is missing the Homebrew or mise line. Run `install.sh` again: it adds them.
- Docker checks fail with `Cannot connect to the Docker daemon`: Docker is still starting. The first start takes a few minutes. Check `colima status`, wait, and run the smoke test again.
- Anything else: show the user the output, and say what you think is wrong.

## 6. Tell the user what is left

If this skill is a downloaded copy in `~/.claude/skills/brework-setup` (not a link), offer to swap it for a link to `~/.brework`, so it stays up to date. Ask first:

```bash
rm -rf ~/.claude/skills/brework-setup
ln -s ~/.brework/.claude/skills/brework-setup ~/.claude/skills/brework-setup
```

Report what you did, the smoke test result, and these manual steps (brework cannot do them):

- Open Xcode once to finish its setup (if they installed everything).
- Sign in to the apps they use, and to the CLI tools that need an account: `gh auth login`, `aws configure`, `doctl auth init`, `supabase login`, `gcloud auth login`, and `copilot` on its first start.
