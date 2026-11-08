# brework: advanced

You don't need this page to use brework. The [README](../README.md) has everything for a normal install.

## Other ways to install

### Which version you get

The install command installs one release of brework: the version in its address, like `v1.6.0` in `.../sgnd/brework/v1.6.0/install.sh`. The script names the same version in `BREWORK_VERSION`. It downloads exactly that release (a git tag) to `~/.brework`, and checks it first:

- The downloaded `install.sh` must name the same version as the script you ran.
- A release never changes. Once your Mac has a release, GitHub must still have the same one, or the script stops and asks you to report it.
- If you changed files in `~/.brework` (or made commits there), the script stops instead of overwriting them. To keep your own list, [make it yours](#make-it-yours).

When a check fails, nothing from the list is installed.

Running the same command again keeps that release. To update, run the command of a newer release: the [README](../README.md#install) and [Releases](https://github.com/sgnd/brework/releases/latest) show it. To see which release you have: `git -C ~/.brework describe --tags --always`.

Installed before v1.6.0? Then `~/.brework` follows `main`. A newer install command moves it to its release, unless you changed it.

### Install main instead of a release

`main` gets every change as soon as it is merged, before it is released. Only use it to try out changes to brework. Set `BREWORK_REF` to the branch (or tag) you want:

```bash
curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | BREWORK_REF=main bash
```

The script then installs `main` instead of its own release. The release checks above do not apply to a branch, and `main` can change between two runs. Set `BREWORK_REF=main` every time: without it, the install command moves `~/.brework` back to its release.

### Install from a downloaded copy

If you already downloaded this repo, run the script from there:

```bash
./install.sh
```

Or, for only the command-line tools:

```bash
./install.sh --cli-only
```

The script then uses that folder as it is, instead of `~/.brework`, and does not update it. Where the docs say `~/.brework`, use your folder (for example `scripts/smoke-test.sh` in that folder). `./install.sh --help` shows the options.

### Install without the script

1. Install [Homebrew](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   At the end, Homebrew shows "Next steps". Run those commands, so your terminal can find `brew`.

2. Download the newest release (see [Releases](https://github.com/sgnd/brework/releases/latest)) and install everything:

   ```bash
   git clone --depth 1 --branch v1.6.0 https://github.com/sgnd/brework.git ~/.brework
   cd ~/.brework
   brew bundle install
   mise use --global $(grep '^MISE_TOOLS=' install.sh | cut -d'"' -f2)   # the versions in MISE_TOOLS
   ```

   For only the command-line tools, replace `brew bundle install` with `HOMEBREW_BREWORK_CLI_ONLY=1 brew bundle install`. For the remote desktop apps too, use `HOMEBREW_BREWORK_REMOTE_DESKTOP=1 brew bundle install`.

3. Set up `docker compose` and `docker buildx`:

   ```bash
   mkdir -p ~/.docker/cli-plugins
   ln -sfn "$(brew --prefix)"/lib/docker/cli-plugins/docker-* ~/.docker/cli-plugins/
   ```

4. For the `PATH`, the shell tools, `delta` and starting Docker, do what steps 2, 6 and 7 of [`install.sh`](../install.sh) do: add the lines it shows to the files it names, and run the commands.

### Install with an AI agent

This repo has an [agent skill](../.claude/skills/brework-setup/SKILL.md) that tells an AI coding agent how to run the installer, fix common errors, and check that every tool works. To use it with [Claude Code](https://claude.com/claude-code) (install Claude Code first), add the skill to your skills folder:

```bash
mkdir -p ~/.claude/skills/brework-setup
curl -fsSL https://raw.githubusercontent.com/sgnd/brework/v1.6.0/.claude/skills/brework-setup/SKILL.md -o ~/.claude/skills/brework-setup/SKILL.md
```

Then start Claude Code in any folder and ask: "Set up my Mac with brework". You still type your password yourself when the installer asks for it.

Keep the skill a copy. Don't make it a link to `~/.brework`: the agent follows these instructions and can run commands on your Mac, so they should only change when you choose to. To update the skill, first install a newer release, then see what changed and copy it:

```bash
diff -ru ~/.claude/skills/brework-setup ~/.brework/.claude/skills/brework-setup   # read what changed
rm -rf ~/.claude/skills/brework-setup
cp -R ~/.brework/.claude/skills/brework-setup ~/.claude/skills/brework-setup
```

Made it a link before v1.6.0? The last two lines replace the link with a copy.

Other agents that support agent skills can use the same `SKILL.md`. Put it in their skills folder.

## See what's missing or out of date

To see what is missing or out of date, without installing anything:

```bash
cd ~/.brework
brew bundle check --verbose
```

If you installed with `--cli-only`, use `HOMEBREW_BREWORK_CLI_ONLY=1 brew bundle check --verbose`, or it lists the apps as missing.

## Change the list

Run the commands below in the brework folder (`~/.brework` if you used the install command).

When `~/.brework` has changes, the install command stops and shows them, instead of overwriting them (see [Which version you get](#which-version-you-get)). To keep your own list, [make it yours](#make-it-yours).

### Add a tool or an app

1. Open the [`Brewfile`](../Brewfile) for a command-line tool, or [`Brewfile.apps`](../Brewfile.apps) for an app (also App Store apps). The top of each file shows how to add one.
2. Add a line in the right section, with a short comment.
3. Check and install it:

   ```bash
   scripts/validate-brewfile.sh   # does every package still exist?
   brew bundle install            # install what you added
   ```

   If you installed with `--cli-only`, put `HOMEBREW_BREWORK_CLI_ONLY=1` in front of `brew bundle install`, or it also installs all the apps.

### Remove a tool or an app

Deleting a line from the `Brewfile` or `Brewfile.apps` does not uninstall it. Delete the line, then uninstall it yourself:

```bash
brew uninstall ripgrep           # a command-line tool
brew uninstall --cask warp       # an app
```

App Store apps: drag them from `/Applications` to the Trash.

### Tips

- Do not use `brew bundle dump` to update the list. It makes a new file without the sections and comments.
- To see what is installed on your Mac but missing from both lists:

  ```bash
  brew bundle cleanup         # shows the list, then asks: press n to keep everything
  ```

  **Careful:** if you press `y`, it uninstalls everything in that list. Never add `--force`: it uninstalls without asking. Installed with `--remote-desktop`? Put `HOMEBREW_BREWORK_REMOTE_DESKTOP=1` in front, or TeamViewer and AnyDesk are in that list too.

GitHub checks every change to the list. See [CONTRIBUTING.md](../CONTRIBUTING.md#how-github-checks-the-list).

## Make it yours

This list is one person's setup. To make your own:

1. [Fork this repo](https://github.com/sgnd/brework/fork) on GitHub.
2. Edit the `Brewfile` and `Brewfile.apps`: remove what you don't need (for example the chat apps) and add your own tools.
3. In `install.sh`, change `REPO_URL` to your fork's address.
4. If you already have a `~/.brework` folder from this repo, delete it: `rm -rf ~/.brework`.
5. Install from your fork's `main`. `BREWORK_REF=main` is needed: the release in `BREWORK_VERSION` is a release of this repo, without your changes.

   ```bash
   curl -fsSL https://raw.githubusercontent.com/YOUR-NAME/brework/main/install.sh | BREWORK_REF=main bash
   ```

   Or make your own releases: set `BREWORK_VERSION` to a new tag name (like `mine-1`) and commit, then tag that commit and push the tag (`git tag mine-1 && git push origin mine-1`). Use the tag instead of `main` in the address, without `BREWORK_REF`.

## Docker (Colima)

Don't want Docker to start every time you log in? Run `brew services stop colima`, and start it yourself with `colima start` when you need it. Running the install command again turns the autostart back on, unless Colima is running at that moment.

Need a local Kubernetes cluster? Run `colima stop`, then `colima start --kubernetes`.

## How it works

`install.sh` does this:

1. Installs Homebrew, if you don't have it yet
2. Adds Homebrew to your `PATH` for every shell: `~/.zshenv` (every zsh, also `ssh mac COMMAND`), `~/.zprofile` (a terminal, code editors and AI agents) and `~/.bash_profile` (bash)
3. Downloads the release in `BREWORK_VERSION` to `~/.brework` (a hidden folder: press ⌘ + Shift + . in Finder to see it), after it checks that release. It stops if you changed files there. See [Which version you get](#which-version-you-get).
4. Installs everything in the `Brewfile` and `Brewfile.apps` (only the `Brewfile` with `--cli-only`, and TeamViewer and AnyDesk only with `--remote-desktop`). It also installs `usql` and `mongosh` with `mise`, at fixed versions (`MISE_TOOLS` in `install.sh`): `usql` is not in Homebrew core, and Homebrew's `mongosh` needs a second Node.js.
5. Sets up `docker compose` and `docker buildx`
6. Turns on `mise`, `direnv`, `zoxide` and `fzf` in `~/.zshrc`, and shows git diffs with `delta`. It also adds the `mise` tools to the same three files as Homebrew, so code editors, AI agents and scripts find them too (they don't read `~/.zshrc`).
7. Starts Docker (Colima) now and every time you log in

It keeps settings you already have: a tool that is already in your `~/.zshrc`, or a git pager you already picked, stays as it is. Two things it does change: it links `docker compose` and `docker buildx` into `~/.docker/cli-plugins` (replacing Docker Desktop's links), and Colima makes itself the active Docker context when it starts.

### Why three shell files?

A terminal, a code editor, an AI agent and a script each start the shell in a different way, and each way reads different files:

| File | Read by |
| --- | --- |
| `~/.zshrc` | A Terminal window. brework turns on `mise`, `direnv`, `zoxide` and `fzf` here |
| `~/.zshenv` | Every zsh: Terminal, editors, AI agents, scripts, `ssh mac COMMAND` |
| `~/.zprofile` | A Terminal window, most editors and AI agents. Just before this file, macOS puts its own older tools (like `python3` 3.9) first again, so brework adds the same lines here |
| `~/.bash_profile` | bash |

brework adds Homebrew and the `mise` tools to the last three, so every shell finds the same tools. The [check](../README.md#check-that-everything-works) tests all of them.

### The checks

- `scripts/validate-brewfile.sh` checks that every package in the lists still exists.
- `scripts/smoke-test.sh` gives every tool a small real task on your Mac (for example: `age` encrypts and decrypts a file, `gitleaks` finds a planted fake token, `docker` runs a container). It also checks that every command is found in Terminal, code editors, AI agents and scripts, and that every app Homebrew puts in `/Applications` is signed and made for Apple Silicon. The Docker checks always use the local Docker (Colima), and the Kubernetes checks never use your real clusters. Tools that need an account, like `gh` and `aws`, only show their version.
- GitHub runs the first for every change, and the second when a pull request changes a Brewfile, `install.sh` or `smoke-test.sh`, and every Monday. See [CONTRIBUTING.md](../CONTRIBUTING.md#how-github-checks-the-list).

## `command not found` in a cron job or launchd agent

cron and launchd don't start a shell, so they don't read `~/.zshenv` or any other file, and their `PATH` has no Homebrew. Write the full path in the job, like `/opt/homebrew/bin/kubectl`, or `mise exec -- usql` with `/opt/homebrew/bin/mise`.

## Remove brework

This undoes the settings `install.sh` made. The tools and apps stay installed.

1. Stop Docker (Colima) from starting at login:

   ```bash
   brew services stop colima
   ```

2. Remove the lines brework added to your shell files (each has `# added by brework`):

   ```bash
   for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.bash_profile; do
     [ -f "$file" ] && sed -i '' '/# added by brework/d' "$file"
   done
   [ -s ~/.bash_profile ] || rm -f ~/.bash_profile   # if it is now empty
   ```

3. Remove the tools brework installed with mise, and delta as your git pager (skip this if you set the pager yourself):

   ```bash
   mise unuse --global usql mongosh
   git config --global --unset core.pager
   git config --global --unset interactive.diffFilter
   ```

4. Remove the `docker compose` and `docker buildx` links that brework made (only links into Homebrew are removed):

   ```bash
   find ~/.docker/cli-plugins -lname "$(brew --prefix)/*" -delete
   ```

   If you use Docker Desktop, open it once afterwards, so it puts its own links back.

5. Delete the brework folder (or the folder you installed from):

   ```bash
   rm -rf ~/.brework
   ```

To remove a tool or an app too, see [Remove a tool or an app](#remove-a-tool-or-an-app). To remove Homebrew itself, use its [uninstall script](https://github.com/Homebrew/install#uninstall-homebrew).

## Project files

| File | What it does |
| --- | --- |
| [`Brewfile`](../Brewfile) | The list of command-line tools. It also loads `Brewfile.apps` |
| [`Brewfile.apps`](../Brewfile.apps) | The list of apps, App Store apps included |
| [`install.sh`](../install.sh) | Sets up a Mac in one command |
| [`docs/advanced.md`](advanced.md) | This page |
| [`scripts/validate-brewfile.sh`](../scripts/validate-brewfile.sh) | Checks that every package in the lists and every `MISE_TOOLS` version still exists, and that the README names the macOS version each App Store app needs |
| [`scripts/smoke-test.sh`](../scripts/smoke-test.sh) | Checks that every installed tool really works |
| [`.github/workflows/validate.yml`](../.github/workflows/validate.yml) | Runs the checks on GitHub |
| [`.github/workflows/e2e.yml`](../.github/workflows/e2e.yml) | Tests `install.sh` for real on a Mac on GitHub |
| [`.github/actionlint.yaml`](../.github/actionlint.yaml) | Settings for the workflow check (actionlint) |
| [`.github/dependabot.yml`](../.github/dependabot.yml) | Keeps the GitHub Actions up to date |
| [`CHANGELOG.md`](../CHANGELOG.md) | What changed in each release |
| [`CONTRIBUTING.md`](../CONTRIBUTING.md), [`SECURITY.md`](../SECURITY.md), [`CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | How to help, report a security problem, and behave |
| [`.github/ISSUE_TEMPLATE`](../.github/ISSUE_TEMPLATE) | The forms for suggesting a tool and reporting a bug |
| [`.claude/skills/brework-setup/SKILL.md`](../.claude/skills/brework-setup/SKILL.md) | Tells AI coding agents how to set up a Mac with brework and check it |
| [`.claude/skills/brework-maintain/SKILL.md`](../.claude/skills/brework-maintain/SKILL.md) | Tells AI coding agents how to add or remove a package |
