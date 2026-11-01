# brework

[![Validate](https://github.com/sgnd/brework/actions/workflows/validate.yml/badge.svg)](https://github.com/sgnd/brework/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Set up a Mac for software development and IT operations (Dev & Ops) with one command.

brework = brew + work: [Homebrew](https://brew.sh), ready for work.

One command installs about 55 command-line tools (programs you use by typing in Terminal) and about 20 apps, and sets them up. A second command checks that they all work. You can install only the command-line tools.

**You need:** a Mac with Apple Silicon (M1 or newer), macOS 15 or newer, your Mac password, about 40 GB of free disk space, and 30 to 60 minutes. See [Requirements](#requirements), then [Install](#install).

New to these words? See [Words used here](#words-used-here). To see every tool and app, go to [What's inside](#whats-inside).

## Is it for me?

- **Yes**, if you write code or run servers and want a new Mac ready for work, or the same tools on every Mac you use.
- **Yes**, if you want a list to start from: [make it yours](docs/advanced.md#make-it-yours) and change it.
- **No**, if your Mac has an Intel chip. See [Intel Macs](#intel-macs).

## Requirements

- A Mac with Apple Silicon (M1 or newer). To check: Apple menu > About This Mac. It says **Chip: Apple M1** (or M2, M3, ...). The Homebrew installer no longer works on Intel Macs (see [Intel Macs](#intel-macs)).
- macOS 15 (Sequoia) or newer. About This Mac shows your version. Xcode and WhatsApp need a newer macOS: see [Troubleshooting](#troubleshooting).
- An admin account (the installer asks for your password). To check: System Settings > Users & Groups. Your name says **Admin**.
- About 40 GB of free disk space (about 20 GB with `--cli-only`). Docker needs more as you add images. To check: System Settings > General > Storage.
- An internet connection
- An Apple Account signed in to the App Store (for the App Store apps, not needed with `--cli-only`)

### Intel Macs

brework does not work on Intel Macs. The Homebrew installer stops on them, and Homebrew plans to stop working on Intel Macs in or after September 2027 ([Homebrew support tiers](https://docs.brew.sh/Support-Tiers)).

On an Intel Mac, you can still use the lists as a shopping list: every name in [What's inside](#whats-inside) links to its official website, where you can download it. [MacPorts](https://github.com/macports/macports-base) also has many of the command-line tools.

## Install

**Before you start:**

- Sign in to the Mac App Store (not needed with `--cli-only`).
- Plug in your Mac and keep the lid open. The install takes 30 to 60 minutes, depending on your internet.
- Choose what to install: **everything** (tools and apps), or **only the command-line tools** (`--cli-only`, no apps).

**Is this safe?** The command runs a script from the internet on your Mac. The script only installs what is in these lists and sets it up. Your password goes to macOS, not to brework. You can [read `install.sh`](install.sh) first.

1. Open Terminal: press Command (⌘) + Space, type `Terminal`, and press Return.
2. Copy one of these lines (on GitHub, click the copy icon at the right of the box), paste it into Terminal (⌘V), and press Return.

   Everything:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash
   ```

   Only the command-line tools:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash -s -- --cli-only
   ```

3. When it asks for your password, type your Mac login password and press Return. **You don't see anything while you type.** That is normal. It may ask for your password more than once (some apps ask again), and may ask you to press Return. Some apps open their own window that asks for your password or permission: allow it, then go back to Terminal. Look at Terminal every few minutes.
4. Wait until it says `Done!`. Then open a new Terminal window (⌘N) and go on with [After you install](#after-you-install).

If it ends with an error, read the last lines, then see [Troubleshooting](#troubleshooting). An error about only Xcode or WhatsApp is explained there too. You can run the same line again at any time: it installs what is missing and updates what is out of date.

**What does it change on my Mac?**

- It installs Homebrew (an installer for developer tools) and everything in the lists. Tools and apps you already have from Homebrew are updated.
- It keeps a copy of this project in `~/.brework`, a hidden folder in your home folder (press ⌘ + Shift + . in Finder to see it).
- It adds a few lines to the files your terminal reads when it starts, so the tools work everywhere: in Terminal, in code editors and in AI agents. Each line ends with `# added by brework`.
- It starts Docker (Colima) in the background, now and every time you log in. Docker runs in a small Linux VM that uses about 2 GB of memory. To turn that off, see [Docker (Colima)](docs/advanced.md#docker-colima).

Most settings you already have stay as they are. For the details, see [How it works](docs/advanced.md#how-it-works).

## After you install

1. Docker starts by itself. The first start downloads a small Linux VM, so it takes a few minutes. Check that it works:

   ```bash
   docker run --rm hello-world
   ```

2. For icons in the terminal, pick the font **JetBrainsMono Nerd Font** (some apps list it as **JetBrainsMono NF**). In Terminal: Terminal > Settings > Profiles > Text > Font > Change. Then run `eza --icons`. The terminal does not switch fonts by itself.
3. Open Xcode once to finish its setup (not with `--cli-only`).
4. Open the apps and sign in to the ones you use.
5. Sign in to the command-line tools you have an account for: `gh auth login`, `aws configure`, `doctl auth init`, `supabase login`, and `copilot` (it asks on its first start). Skip the ones you don't use.

## Check that everything works

First wait until `docker run --rm hello-world` works (see above). Then, in a new Terminal window (⌘N), run:

```bash
~/.brework/scripts/smoke-test.sh
```

Add `--cli-only` if you installed only the command-line tools.

It tries every tool. The last line must say `0 failed`. If it doesn't, read the lines under each `FAIL`, then see [Troubleshooting](#troubleshooting) or [open an issue](https://github.com/sgnd/brework/issues/new?template=bug-report.yml).

## Keep everything up to date

```bash
brew update && brew upgrade
```

App Store apps update through the App Store, as usual.

To get the newest list and install what was added to it, run the [install command](#install) again. This also updates everything in the list, App Store apps included.

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

## Troubleshooting

**"It seems there is already an App"**
The app was installed without Homebrew (for example, dragged into `/Applications`). Let Homebrew take it over instead of installing it again. It asks for your password. Replace `visual-studio-code` with the name in the error message:

```bash
brew install --cask --adopt visual-studio-code
```

**An App Store app did not install**
Open the App Store, sign in, and run the [install command](#install) again.

**Xcode or WhatsApp did not install**
Your macOS is too old for them: Xcode needs macOS 26.6 or newer today, and WhatsApp needs macOS 15.1. Everything else is installed. Update macOS in System Settings > General > Software Update, then run the install command again. Or skip them if you don't need them. For an older Xcode, see [Apple's developer site](https://developer.apple.com/download/all/?q=xcode).

**"This terminal runs in Rosetta (Intel mode)"**
Your terminal app is set to open using Rosetta. In Finder, open Applications (Terminal is in Applications > Utilities), select your terminal app, choose File > Get Info, and turn off "Open using Rosetta". Then open a new Terminal window.

**`command not found` right after the install**
Open a new Terminal window (⌘N). A window that was open during the install does not know the new tools yet. Still not found? Run the [check](#check-that-everything-works): it says what is wrong.

**`docker: Cannot connect to the Docker daemon`**
Docker is still starting (the first start takes a few minutes), or it is not running. Check with `colima status`. Start it with `brew services restart colima`.

**Why Colima and not Docker Desktop?**
Colima is free, open source and runs from the terminal. It gives you the same `docker` commands.

## Words used here

| Word | What it means |
| --- | --- |
| Terminal | The Mac app where you type commands. Open it with ⌘ + Space, then type `Terminal` |
| Command-line tool (CLI) | A program you use by typing in Terminal, like `git` |
| App | A program with a window, like VS Code or Slack |
| Colima | The free program that runs Docker on your Mac |
| Homebrew | A free installer for developer tools and apps on a Mac. Its command is `brew` |
| `Brewfile` | A list of what Homebrew should install |
| Shell | The program inside Terminal that reads your commands. On a Mac it is zsh |
| `PATH` | The list of folders where the shell looks for commands. If a tool's folder is not in it, you get `command not found` |
| Docker, container | A way to run an app with everything it needs, separate from the rest of your Mac |
| `mise` | A tool that installs a language, like Python, at the version a project needs |
| AI agent | An AI that runs commands for you, like [Claude Code](https://claude.com/claude-code) |
| Repo | A project folder on GitHub, like this one |
| Fork | Your own copy of a repo on GitHub, which you can change |
| VM (virtual machine) | A computer that runs inside your computer |

## More

For people who want to go further, see [docs/advanced.md](docs/advanced.md):

- [Other ways to install](docs/advanced.md#other-ways-to-install): from a downloaded copy, without the script, or with an AI agent
- [Change the list](docs/advanced.md#change-the-list) and [make it yours](docs/advanced.md#make-it-yours)
- [Docker (Colima)](docs/advanced.md#docker-colima): stop it from starting at login, or run Kubernetes
- [How it works](docs/advanced.md#how-it-works): what the script changes, and why
- [See what's missing or out of date](docs/advanced.md#see-whats-missing-or-out-of-date), and [project files](docs/advanced.md#project-files)

## Contributing

Ideas are welcome. To suggest a tool, report a bug or send a pull request, see [CONTRIBUTING.md](CONTRIBUTING.md). Found a security problem? See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE). You can use, copy and change this project freely.
