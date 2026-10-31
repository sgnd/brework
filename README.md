# masbrew

[![Validate](https://github.com/sgnd/masbrew/actions/workflows/validate.yml/badge.svg)](https://github.com/sgnd/masbrew/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Set up a Mac for Dev & Ops work with one command.

This repo has a [Homebrew](https://brew.sh) `Brewfile`: a list of the tools and apps to install.

## What's inside

Click a name to open its official website. You can also download it from there without Homebrew.

### CLI tools

| Category | Packages |
| --- | --- |
| Version control | [git](https://git-scm.com), [gh](https://cli.github.com), [git-delta](https://dandavison.github.io/delta/) |
| Code quality & Git hooks | [pre-commit](https://pre-commit.com), [shellcheck](https://www.shellcheck.net), [hadolint](https://github.com/hadolint/hadolint) |
| Security & secrets | [age](https://github.com/FiloSottile/age), [sops](https://getsops.io), [gitleaks](https://gitleaks.io), [trivy](https://trivy.dev) |
| Cloud CLIs | [awscli](https://aws.amazon.com/cli/), [doctl](https://docs.digitalocean.com/reference/doctl/), [supabase](https://supabase.com/docs/reference/cli/about) |
| Infrastructure as Code & server setup | [opentofu](https://opentofu.org), [ansible](https://www.ansible.com), [ansible-lint](https://docs.ansible.com/projects/lint/) |
| Containers | [colima](https://github.com/abiosoft/colima), [docker](https://docs.docker.com/engine/install/binaries/), [docker-compose](https://github.com/docker/compose), [docker-buildx](https://github.com/docker/buildx) |
| Kubernetes | [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/), [helm](https://helm.sh), [kustomize](https://github.com/kubernetes-sigs/kustomize), [kubectx](https://github.com/ahmetb/kubectx), [stern](https://github.com/stern/stern) |
| JSON, YAML & HTTP | [jq](https://jqlang.github.io/jq/), [yq](https://github.com/mikefarah/yq), [httpie](https://httpie.io) |
| Languages & environment | [mise](https://mise.jdx.dev), [direnv](https://direnv.net) |
| Shell & CLI utilities | [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://junegunn.github.io/fzf/), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [bat](https://github.com/sharkdp/bat), [eza](https://eza.rocks), [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree), [tlrc](https://tldr.sh/tlrc/), [watch](https://gitlab.com/procps-ng/procps), [wget](https://www.gnu.org/software/wget/), [rsync](https://rsync.samba.org) |
| System maintenance | [mole](https://mole.fit), [mas](https://github.com/mas-cli/mas) |

### Apps

| Category | Apps |
| --- | --- |
| Editors & terminals | [Visual Studio Code](https://code.visualstudio.com/download), [Cursor](https://cursor.com/downloads), [Warp](https://www.warp.dev/download) |
| AI assistants | [Claude](https://claude.com/download), [ChatGPT](https://openai.com/chatgpt/download/), [GitHub Copilot CLI](https://github.com/github/copilot-cli/releases) |
| Networking & VPN | [Cloudflare WARP](https://one.one.one.one), [OpenVPN Connect](https://openvpn.net/client/) |
| Browsers | [Google Chrome](https://www.google.com/chrome/) |
| Fonts | [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads) |
| Mac App Store | [Xcode](https://apps.apple.com/app/id497799835), [Termius](https://apps.apple.com/app/id1176074088), [Telegram](https://apps.apple.com/app/id747648890), [WhatsApp](https://apps.apple.com/app/id310633997), [WeChat](https://apps.apple.com/app/id836500024) |

See the [`Brewfile`](Brewfile) for a short description of each one.

Programming languages (Node.js, Python, Go, ...) are not in this list. Install them per project with [`mise`](https://mise.jdx.dev).

## Requirements

- A Mac with Apple Silicon (M1 or newer). The Homebrew installer no longer works on Intel Macs.
- macOS 15 (Sequoia) or newer. Xcode needs the newest macOS (26.6 or newer today). On an older macOS, everything else installs and the script ends with an error about Xcode.
- An admin account (the installer asks for your password)
- About 20 GB of free disk space
- An internet connection
- An Apple ID signed in to the App Store (for the App Store apps)

Xcode from the App Store needs the newest macOS. If your macOS is older, see [Troubleshooting](#troubleshooting).

## Install

1. Sign in to the Mac App Store.
2. Run:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/sgnd/masbrew/main/install.sh | bash
   ```

This runs a script from the internet on your Mac. It is short and easy to read, so you can [read `install.sh`](install.sh) first.

The script does this for you:

1. Installs Homebrew, if you don't have it yet
2. Adds Homebrew to your `PATH` (in `~/.zprofile`, for the zsh shell that macOS uses)
3. Downloads this repo to `~/masbrew`
4. Installs everything in the `Brewfile`
5. Sets up `docker compose` and `docker buildx`

You can run it again at any time. It installs what is missing and updates what is out of date.

If you already downloaded this repo, run the script from there:

```bash
./install.sh
```

To see what is missing or out of date, without installing anything:

```bash
cd ~/masbrew
brew bundle check --verbose
```

### Install without the script

1. Install [Homebrew](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   At the end, Homebrew shows "Next steps". Run those commands, so your terminal can find `brew`.

2. Download this repo and install everything:

   ```bash
   git clone https://github.com/sgnd/masbrew.git ~/masbrew
   cd ~/masbrew
   brew bundle install
   ```

3. Set up `docker compose` and `docker buildx`:

   ```bash
   mkdir -p ~/.docker/cli-plugins
   ln -sfn "$(brew --prefix)"/lib/docker/cli-plugins/docker-* ~/.docker/cli-plugins/
   ```

## After you install

1. Open a new terminal, so it can find the new tools.
2. Start Docker. The first start downloads a small Linux VM, so it takes a few minutes.

   ```bash
   colima start                 # add --kubernetes for a local Kubernetes cluster
   docker run --rm hello-world  # check that Docker works
   ```

3. Open Xcode once to finish its setup.
4. Open the apps and sign in to the ones you use.

## Keep everything up to date

```bash
brew update && brew upgrade
```

App Store apps update through the App Store, as usual.

To get the newest list and install what was added to it, run the [install command](#install) again. This also updates everything in the list, App Store apps included.

## Change the list

Run the commands below in the masbrew folder (`~/masbrew` if you used the install command).

### Add a tool or an app

1. Open the [`Brewfile`](Brewfile). The top of the file shows how to add a tool or an app.
2. Add a line in the right section, with a short comment.
3. Check and install it:

   ```bash
   scripts/validate-brewfile.sh   # does every package still exist?
   brew bundle install            # install what you added
   ```

### Remove a tool or an app

Deleting a line from the `Brewfile` does not uninstall it. Delete the line, then uninstall it yourself:

```bash
brew uninstall ripgrep           # a CLI tool
brew uninstall --cask warp       # an app
```

App Store apps: drag them from `/Applications` to the Trash.

### Tips

- Do not use `brew bundle dump` to update the list. It makes a new file without the sections and comments.
- To see what is installed on your Mac but missing from the `Brewfile`:

  ```bash
  brew bundle cleanup         # shows the list, then asks: press n to keep everything
  ```

[GitHub Actions](.github/workflows/validate.yml) runs `validate-brewfile.sh` on every push to `main`, every pull request and every Monday. It also checks the shell scripts and the links in this README.

When a pull request changes the `Brewfile` or `install.sh`, [another check](.github/workflows/e2e.yml) removes Homebrew from a GitHub Mac and then runs `install.sh` for real. Some things are left out, because GitHub's Macs cannot do them: App Store apps (no Apple ID), starting Docker (Colima cannot start a VM there) and typing a password. The test also starts with this repo already in `~/masbrew`, so it does not test the first download of the repo.

## Make it yours

This list is one person's setup. To make your own:

1. [Fork this repo](https://github.com/sgnd/masbrew/fork) on GitHub.
2. Edit the `Brewfile`: remove what you don't need (for example the chat apps) and add your own tools.
3. In `install.sh`, change `REPO_URL` to your fork's address.
4. If you already have a `~/masbrew` folder from this repo, delete it.
5. Install with your fork's link:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/YOUR-NAME/masbrew/main/install.sh | bash
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
The newest Xcode needs the newest macOS. Update macOS in System Settings > General > Software Update, then run the install command again. Or download an older Xcode from [Apple's developer site](https://developer.apple.com/download/all/?q=xcode).

**"This terminal runs in Rosetta (Intel mode)"**
Your terminal is set to open using Rosetta. In Finder, open Applications (Terminal is in Applications > Utilities), select your terminal app, choose File > Get Info, and turn off "Open using Rosetta". Then open a new terminal.

**`docker: Cannot connect to the Docker daemon`**
Docker is not running. Start it with `colima start`.

**Why Colima and not Docker Desktop?**
Colima is free, open source and runs from the terminal. It gives you the same `docker` commands.

## Project files

| File | What it does |
| --- | --- |
| [`Brewfile`](Brewfile) | The list of tools and apps |
| [`install.sh`](install.sh) | Sets up a Mac in one command |
| [`scripts/validate-brewfile.sh`](scripts/validate-brewfile.sh) | Checks that every package in the list still exists |
| [`.github/workflows/validate.yml`](.github/workflows/validate.yml) | Runs the checks on GitHub |
| [`.github/workflows/e2e.yml`](.github/workflows/e2e.yml) | Tests `install.sh` for real on a Mac on GitHub |
| [`.claude/skills/masbrew-maintain/SKILL.md`](.claude/skills/masbrew-maintain/SKILL.md) | Tells AI coding agents how to add or remove a package |

## Contributing

Ideas are welcome. Open an issue or a pull request.

## License

[MIT](LICENSE). You can use, copy and change this project freely.
