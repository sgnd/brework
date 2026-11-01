# brework

[![Validate](https://github.com/sgnd/brework/actions/workflows/validate.yml/badge.svg)](https://github.com/sgnd/brework/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Set up a Mac for software development and IT operations (Dev & Ops) with one command.

brework = brew + work: [Homebrew](https://brew.sh), ready for work.

One command installs about 55 command-line tools (programs you use by typing in Terminal) and about 20 apps, sets them up, and checks that they all work. You can install only the command-line tools.

New to these words? See [Words used here](#words-used-here).

## Is it for me?

- **Yes**, if you write code or run servers and want a new Mac ready for work, or the same tools on every Mac you use.
- **Yes**, if you want a list to start from: [make it yours](#make-it-yours) and change it.
- **No**, if your Mac has an Intel chip. See [Intel Macs](#intel-macs).

## What's inside

Click a name to open its official website. You can also download it from there without Homebrew.

### Command-line tools (`Brewfile`)

| Category | Used for | Tools |
| --- | --- | --- |
| Version control | Save the history of your code, and work with GitHub | [git](https://git-scm.com), [gh](https://cli.github.com), [git-delta](https://dandavison.github.io/delta/), [git-lfs](https://git-lfs.com) |
| Code quality & Git hooks | Find mistakes in scripts, Dockerfiles and GitHub workflows before you commit | [pre-commit](https://pre-commit.com), [shellcheck](https://www.shellcheck.net), [hadolint](https://github.com/hadolint/hadolint), [shfmt](https://github.com/mvdan/sh), [actionlint](https://rhysd.github.io/actionlint/) |
| Security & secrets | Encrypt secrets, and find leaked passwords and security problems | [age](https://github.com/FiloSottile/age), [sops](https://getsops.io), [gitleaks](https://gitleaks.io), [trivy](https://trivy.dev) |
| Cloud CLIs | Manage AWS, DigitalOcean and Supabase from the terminal | [awscli](https://aws.amazon.com/cli/), [doctl](https://docs.digitalocean.com/reference/doctl/), [supabase](https://supabase.com/docs/reference/cli/about) |
| Infrastructure as Code & server setup | Create cloud servers from code, and set them up automatically | [opentofu](https://opentofu.org), [ansible](https://www.ansible.com), [ansible-lint](https://docs.ansible.com/projects/lint/) |
| Containers | Run and build Docker containers, without Docker Desktop | [colima](https://github.com/abiosoft/colima), [docker](https://docs.docker.com/engine/install/binaries/), [docker-compose](https://github.com/docker/compose), [docker-buildx](https://github.com/docker/buildx), [docker-credential-helper](https://github.com/docker/docker-credential-helpers), [crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md) |
| Kubernetes | Manage Kubernetes clusters and the apps on them | [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/), [helm](https://helm.sh), [kustomize](https://github.com/kubernetes-sigs/kustomize), [kubeconform](https://github.com/yannh/kubeconform), [kubectx](https://github.com/ahmetb/kubectx), [stern](https://github.com/stern/stern) |
| JSON, YAML & HTTP | Read and edit config files, and call web APIs | [jq](https://jqlang.github.io/jq/), [yq](https://github.com/mikefarah/yq), [httpie](https://httpie.io) |
| Database clients | Connect to PostgreSQL, MySQL, SQLite, MongoDB, Redis and more | [mongosh](https://www.mongodb.com/docs/mongodb-shell/), [redis-cli](https://redis.io/docs/latest/develop/tools/cli/), [usql](https://github.com/xo/usql) |
| Load testing & benchmarks | Check how fast a website, an API or a command is | [k6](https://k6.io), [hyperfine](https://github.com/sharkdp/hyperfine) |
| Languages & environment | Install Node, Python, Go, ... per project, and save project commands | [mise](https://mise.jdx.dev), [direnv](https://direnv.net), [just](https://just.systems) |
| Shell & CLI utilities | Find files and text fast, jump between folders, download files | [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://junegunn.github.io/fzf/), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [bat](https://github.com/sharkdp/bat), [eza](https://eza.rocks), [tlrc](https://tldr.sh/tlrc/), [watch](https://gitlab.com/procps-ng/procps), [wget](https://www.gnu.org/software/wget/), [doggo](https://doggo.mrkaran.dev/), [rsync](https://rsync.samba.org) |
| System maintenance | Free up disk space | [mole](https://mole.fit) |
| AI in the terminal | Ask an AI for help without leaving the terminal | [GitHub Copilot CLI](https://github.com/github/copilot-cli/releases) |
| Fonts | Show icons in the terminal | [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads) (for the icons in `eza`) |

### Apps (`Brewfile.apps`)

Apps with a window, like VS Code and Slack.

| Category | Apps |
| --- | --- |
| App Store tools | [mas](https://github.com/mas-cli/mas) (installs the App Store apps below) |
| Editors & terminals | [Visual Studio Code](https://code.visualstudio.com/download), [Cursor](https://cursor.com/downloads), [Warp](https://www.warp.dev/download) |
| AI assistants | [Claude](https://claude.com/download), [ChatGPT](https://openai.com/chatgpt/download/) |
| API clients | [Postman](https://www.postman.com/downloads/) |
| Chat | [Slack](https://slack.com/downloads/mac), [Discord](https://discord.com/download), [Telegram](https://apps.apple.com/app/id747648890), [WhatsApp](https://apps.apple.com/app/id310633997), [WeChat](https://apps.apple.com/app/id836500024) |
| Video meetings | [Microsoft Teams](https://www.microsoft.com/microsoft-teams/download-app), [Zoom](https://zoom.us/download), [VooV Meeting](https://voovmeeting.com/download-center.html) |
| Remote access | [Termius](https://apps.apple.com/app/id1176074088), [TeamViewer](https://www.teamviewer.com/en/download/macos/), [AnyDesk](https://anydesk.com/en/downloads/mac-os) |
| Networking & VPN | [Cloudflare WARP](https://one.one.one.one), [OpenVPN Connect](https://openvpn.net/client/) |
| Virtual machines | [UTM](https://mac.getutm.app) |
| Browsers | [Google Chrome](https://www.google.com/chrome/) |
| Apple developer tools | [Xcode](https://apps.apple.com/app/id497799835) |

Telegram, WhatsApp, WeChat, Termius and Xcode come from the Mac App Store.

See the [`Brewfile`](Brewfile) and [`Brewfile.apps`](Brewfile.apps) for a short description of each one.

Programming languages (Node.js, Python, Go, ...) are not in this list. Install them per project with [`mise`](https://mise.jdx.dev).

## Requirements

- A Mac with Apple Silicon (M1 or newer). To check: Apple menu > About This Mac. It says **Chip: Apple M1** (or M2, M3, ...). The Homebrew installer no longer works on Intel Macs (see [Intel Macs](#intel-macs)).
- macOS 15 (Sequoia) or newer. About This Mac shows your version. Some App Store apps need more: Xcode needs macOS 26.6 or newer today, and WhatsApp 15.1. On an older macOS, everything else installs and the script ends with an error about those apps. With `--cli-only`, no App Store apps are installed.
- An admin account (the installer asks for your password)
- About 40 GB of free disk space (about 20 GB with `--cli-only`). Docker needs more as you add images.
- An internet connection
- An Apple ID signed in to the App Store (for the App Store apps, not needed with `--cli-only`)

If Xcode does not install, see [Troubleshooting](#troubleshooting).

### Intel Macs

brework does not work on Intel Macs. The Homebrew installer stops on them, and Homebrew plans to stop working on Intel Macs in or after September 2027 ([Homebrew support tiers](https://docs.brew.sh/Support-Tiers)).

On an Intel Mac, you can still use the lists as a shopping list: every name in [What's inside](#whats-inside) links to its official website, where you can download it. [MacPorts](https://github.com/macports/macports-base) also has many of the CLI tools.

## Install

**Before you start:** sign in to the Mac App Store (not needed with `--cli-only`), and plug in your Mac. The install takes 30 to 60 minutes, depending on your internet.

1. Open Terminal: press Cmd+Space, type `Terminal`, and press Return.
2. Copy this line, paste it into Terminal (Cmd+V), and press Return:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash
   ```

3. When it asks for your password, type your Mac login password and press Return. **You don't see anything while you type.** That is normal.
4. Wait until it says `Done!`. Then open a new Terminal window (Cmd+N) and go on with [After you install](#after-you-install).

If it stops with an error, read the last lines, then see [Troubleshooting](#troubleshooting). You can run the same line again at any time: it installs what is missing and updates what is out of date.

Only want the command-line tools, without the apps? Use this line in step 2:

```bash
curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash -s -- --cli-only
```

**Is this safe?** The line runs a script from the internet on your Mac. It is short and easy to read, so you can [read `install.sh`](install.sh) first.

**What does it change on my Mac?**

- It installs Homebrew (an installer for developer tools) and everything in the lists.
- It keeps a copy of this project in `~/.brework`, a hidden folder in your home folder (press Cmd+Shift+. in Finder to see it).
- It adds a few lines to the files your terminal reads when it starts, so the tools work everywhere: in Terminal, in code editors and in AI agents. Each line ends with `# added by brework`.
- It starts Docker (Colima) in the background, now and every time you log in.

Settings you already have stay as they are. For the details, see [How it works](#how-it-works).

### Install from a downloaded copy

If you already downloaded this repo, run the script from there:

```bash
./install.sh
```

Or, for only the CLI tools:

```bash
./install.sh --cli-only
```

### Install without the script

1. Install [Homebrew](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   At the end, Homebrew shows "Next steps". Run those commands, so your terminal can find `brew`.

2. Download this repo and install everything:

   ```bash
   git clone https://github.com/sgnd/brework.git ~/.brework
   cd ~/.brework
   brew bundle install
   mise use --global usql@0.21.6 mongosh@2.14.1   # see MISE_TOOLS in install.sh
   ```

   For only the CLI tools, run `HOMEBREW_BREWORK_CLI_ONLY=1 brew bundle install` instead of the last line.

3. Set up `docker compose` and `docker buildx`:

   ```bash
   mkdir -p ~/.docker/cli-plugins
   ln -sfn "$(brew --prefix)"/lib/docker/cli-plugins/docker-* ~/.docker/cli-plugins/
   ```

4. For the shell tools, `delta` and starting Docker, copy steps 6 and 7 from [`install.sh`](install.sh).

### Install with an AI agent

This repo has an [agent skill](.claude/skills/brework-setup/SKILL.md) that tells an AI coding agent how to run the installer, fix common errors, and check that every tool works. To use it with [Claude Code](https://claude.com/claude-code), add it to your skills folder first:

```bash
mkdir -p ~/.claude/skills/brework-setup
curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/.claude/skills/brework-setup/SKILL.md -o ~/.claude/skills/brework-setup/SKILL.md
```

Then start Claude Code in any folder and ask: "Set up my Mac with brework". You still type your password yourself when the installer asks for it.

After the install, swap that copy for a link to `~/.brework`. Then the skill updates every time you run the install command again:

```bash
rm -rf ~/.claude/skills/brework-setup
ln -s ~/.brework/.claude/skills/brework-setup ~/.claude/skills/brework-setup
```

Other agents that support agent skills can use the same `SKILL.md`. Put it in their skills folder.

## After you install

1. Open a new terminal. Everything is ready to use. To check that, see [Check that everything works](#check-that-everything-works).
2. Docker starts by itself. The first start downloads a small Linux VM, so it takes a few minutes. Check that it works:

   ```bash
   docker run --rm hello-world
   ```

3. For icons in the terminal, pick the font **JetBrainsMono Nerd Font** (some apps list it as **JetBrainsMono NF**) in your terminal's settings, and run `eza --icons`. The terminal does not switch fonts by itself.
4. Open Xcode once to finish its setup (not with `--cli-only`).
5. Open the apps and sign in to the ones you use.
6. Sign in to the CLI tools you use: `gh auth login`, `aws configure`, `doctl auth init`, `supabase login`, and `copilot` (it asks on its first start).

Need a local Kubernetes cluster? Run `colima stop`, then `colima start --kubernetes`.

Don't want Docker to start every time you log in? Run `brew services stop colima`, and start it yourself with `colima start` when you need it. Running the install command again turns the autostart back on, unless Colima is running at that moment.

## Check that everything works

Open a new terminal and run:

```bash
~/.brework/scripts/smoke-test.sh
```

Add `--cli-only` if you installed only the CLI tools. If you ran `./install.sh` from another folder, run `scripts/smoke-test.sh` from that folder.

It gives every CLI tool one small real task (for example: `age` encrypts and decrypts a file, `gitleaks` finds a planted fake token, `docker` runs a container). It also checks that every command is found, in Terminal and in editors, AI agents and scripts, and that every app is signed and made for Apple Silicon. Tools that need an account, like `gh` and `aws`, only show their version. The last line must say `0 failed`.

## Keep everything up to date

```bash
brew update && brew upgrade
```

App Store apps update through the App Store, as usual.

To get the newest list and install what was added to it, run the [install command](#install) again. This also updates everything in the list, App Store apps included.

To see what is missing or out of date, without installing anything:

```bash
cd ~/.brework
brew bundle check --verbose
```

If you installed with `--cli-only`, use `HOMEBREW_BREWORK_CLI_ONLY=1 brew bundle check --verbose`, or it lists the apps as missing.

## Change the list

Run the commands below in the brework folder (`~/.brework` if you used the install command).

### Add a tool or an app

1. Open the [`Brewfile`](Brewfile) for a CLI tool, or [`Brewfile.apps`](Brewfile.apps) for a GUI or App Store app. The top of each file shows how to add one.
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
brew uninstall ripgrep           # a CLI tool
brew uninstall --cask warp       # an app
```

App Store apps: drag them from `/Applications` to the Trash.

### Tips

- Do not use `brew bundle dump` to update the list. It makes a new file without the sections and comments.
- To see what is installed on your Mac but missing from both lists:

  ```bash
  brew bundle cleanup         # shows the list, then asks: press n to keep everything
  ```

GitHub checks every change to the list. See [CONTRIBUTING.md](CONTRIBUTING.md#how-github-checks-the-list).

## Make it yours

This list is one person's setup. To make your own:

1. [Fork this repo](https://github.com/sgnd/brework/fork) on GitHub.
2. Edit the `Brewfile` and `Brewfile.apps`: remove what you don't need (for example the chat apps) and add your own tools.
3. In `install.sh`, change `REPO_URL` to your fork's address.
4. If you already have a `~/.brework` folder from this repo, delete it.
5. Install with your fork's link:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/YOUR-NAME/brework/main/install.sh | bash
   ```

## Troubleshooting

**"It seems there is already an App"**
The app was installed without Homebrew (for example, dragged into `/Applications`). Let Homebrew take it over instead of installing it again. It asks for your password:

```bash
brew install --cask --adopt visual-studio-code
```

**An App Store app did not install**
Open the App Store, sign in, and run the [install command](#install) again.

**Xcode did not install**
Xcode from the App Store needs a recent macOS (26.6 or newer today). Update macOS in System Settings > General > Software Update, then run the install command again. Or download an older Xcode from [Apple's developer site](https://developer.apple.com/download/all/?q=xcode).

**"This terminal runs in Rosetta (Intel mode)"**
Your terminal is set to open using Rosetta. In Finder, open Applications (Terminal is in Applications > Utilities), select your terminal app, choose File > Get Info, and turn off "Open using Rosetta". Then open a new terminal.

**`command not found` right after the install**
Open a new Terminal window (Cmd+N). A window that was open during the install does not know the new tools yet. Still not found? Run the [check](#check-that-everything-works): it says what is wrong.

**`docker: Cannot connect to the Docker daemon`**
Docker is still starting (the first start takes a few minutes), or it is not running. Check with `colima status`. Start it with `brew services restart colima`.

**`command not found` in a cron job or launchd agent**
cron and launchd don't start a shell, so they don't read `~/.zshenv` or any other file, and their `PATH` has no Homebrew. Write the full path in the job, like `/opt/homebrew/bin/kubectl`, or `mise exec -- usql` with `/opt/homebrew/bin/mise`.

**Why Colima and not Docker Desktop?**
Colima is free, open source and runs from the terminal. It gives you the same `docker` commands.

## How it works

For the curious. You don't need this to use brework.

`install.sh` does this:

1. Installs Homebrew, if you don't have it yet
2. Adds Homebrew to your `PATH` for every shell: `~/.zshenv` (every zsh, also `ssh mac COMMAND`), `~/.zprofile` (a terminal, IDEs and AI agents) and `~/.bash_profile` (bash)
3. Downloads this repo to `~/.brework` (a hidden folder: press Cmd+Shift+. in Finder to see it)
4. Installs everything in the `Brewfile` and `Brewfile.apps` (only the `Brewfile` with `--cli-only`). It also installs `usql` and `mongosh` with `mise`, at fixed versions (`MISE_TOOLS` in `install.sh`): `usql` is not in Homebrew, and Homebrew's `mongosh` needs a second Node.js.
5. Sets up `docker compose` and `docker buildx`
6. Turns on `mise`, `direnv`, `zoxide` and `fzf` in `~/.zshrc`, and shows git diffs with `delta`. It also adds the `mise` tools to the same three files as Homebrew, so IDEs, AI agents and scripts find them too (they don't read `~/.zshrc`).
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

brework adds Homebrew and the `mise` tools to the last three, so every shell finds the same tools. The [check](#check-that-everything-works) tests all of them.

### The checks

- `scripts/validate-brewfile.sh` checks that every package in the lists still exists.
- `scripts/smoke-test.sh` gives every tool a small real task, on your Mac.
- GitHub runs both for every change. See [CONTRIBUTING.md](CONTRIBUTING.md#how-github-checks-the-list).

## Words used here

| Word | What it means |
| --- | --- |
| Terminal | The Mac app where you type commands. Open it with Cmd+Space, then type `Terminal` |
| Command-line tool (CLI) | A program you use by typing in Terminal, like `git` |
| App (GUI) | A program with a window, like VS Code or Slack |
| Homebrew | A free installer for developer tools and apps on a Mac. Its command is `brew` |
| `Brewfile` | A list of what Homebrew should install |
| Shell | The program inside Terminal that reads your commands. On a Mac it is zsh |
| `PATH` | The list of folders where the shell looks for commands. If a tool's folder is not in it, you get `command not found` |
| Docker, container | A way to run an app with everything it needs, separate from the rest of your Mac |
| `mise` | A tool that installs a language, like Python, at the version a project needs |
| AI agent | An AI that runs commands for you, like [Claude Code](https://claude.com/claude-code) |

## Project files

| File | What it does |
| --- | --- |
| [`Brewfile`](Brewfile) | The list of CLI tools. It also loads `Brewfile.apps` |
| [`Brewfile.apps`](Brewfile.apps) | The list of GUI and App Store apps |
| [`install.sh`](install.sh) | Sets up a Mac in one command |
| [`scripts/validate-brewfile.sh`](scripts/validate-brewfile.sh) | Checks that every package in the list still exists, and that the macOS versions in the README are current |
| [`scripts/smoke-test.sh`](scripts/smoke-test.sh) | Checks that every installed tool really works |
| [`.github/workflows/validate.yml`](.github/workflows/validate.yml) | Runs the checks on GitHub |
| [`.github/workflows/e2e.yml`](.github/workflows/e2e.yml) | Tests `install.sh` for real on a Mac on GitHub |
| [`.github/dependabot.yml`](.github/dependabot.yml) | Keeps the GitHub Actions up to date |
| [`CONTRIBUTING.md`](CONTRIBUTING.md), [`SECURITY.md`](SECURITY.md), [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | How to help, report a security problem, and behave |
| [`.github/ISSUE_TEMPLATE`](.github/ISSUE_TEMPLATE) | The forms for suggesting a tool and reporting a bug |
| [`.claude/skills/brework-setup/SKILL.md`](.claude/skills/brework-setup/SKILL.md) | Tells AI coding agents how to set up a Mac with brework and check it |
| [`.claude/skills/brework-maintain/SKILL.md`](.claude/skills/brework-maintain/SKILL.md) | Tells AI coding agents how to add or remove a package |

## Contributing

Ideas are welcome. To suggest a tool, report a bug or send a pull request, see [CONTRIBUTING.md](CONTRIBUTING.md). Found a security problem? See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE). You can use, copy and change this project freely.
