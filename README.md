# brew

[![Validate](https://github.com/sgnd/brew/actions/workflows/validate.yml/badge.svg)](https://github.com/sgnd/brew/actions/workflows/validate.yml)
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
| Infrastructure as Code | [opentofu](https://opentofu.org), [ansible](https://www.ansible.com), [ansible-lint](https://docs.ansible.com/projects/lint/) |
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
| Mac App Store | [Xcode](https://apps.apple.com/app/xcode/id497799835), [Termius](https://apps.apple.com/app/id1176074088), [Telegram](https://apps.apple.com/app/id747648890), [WhatsApp](https://apps.apple.com/app/id310633997), [WeChat](https://apps.apple.com/app/id836500024) |

See the [`Brewfile`](Brewfile) for a short description of each one.

Programming languages (Node.js, Python, Go, ...) are not in this list. Install them per project with [`mise`](https://mise.jdx.dev).

## Supported Macs

| Mac | Status |
| --- | --- |
| Apple Silicon (M1 and newer) | Fully supported. Everything installs fast. |
| Intel | Works, but slower. Homebrew [stopped making ready-made Intel packages](https://docs.brew.sh/Support-Tiers), so most tools are built on your Mac the first time. Homebrew plans to stop supporting Intel Macs in or after September 2027. |

All apps in the list have both an Apple Silicon and an Intel version.

On Apple Silicon, do not run `install.sh` in a Rosetta (Intel mode) terminal. The script checks this and stops.

## Install

1. Sign in to the Mac App Store. This is needed for the App Store apps.
2. Run:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/sgnd/brew/main/install.sh | bash
   ```

[`install.sh`](install.sh) does this for you:

- Installs Homebrew, if you don't have it yet
- Adds Homebrew to your `PATH` (in `~/.zprofile`)
- Downloads this repo to `~/brew` (set `BREW_REPO_DIR` to use another folder)
- Installs everything in the `Brewfile`
- Sets up `docker compose` and `docker buildx`

You can run it again at any time. It skips what is already installed.

If you already downloaded this repo, run the script from there:

```bash
./install.sh           # install everything
./install.sh --check   # only show what is missing
```

Then start Docker:

```bash
colima start                # add --kubernetes for a local Kubernetes cluster
```

### Install without the script

1. Install [Homebrew](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Download this repo and install everything:

   ```bash
   git clone https://github.com/sgnd/brew.git
   cd brew
   brew bundle install
   ```

### "It seems there is already an App"

You see this error when an app was installed without Homebrew (for example, dragged into `/Applications`). Let Homebrew take over the app instead of installing it again. It asks for your password:

```bash
brew install --cask --adopt visual-studio-code
```

## Update the list

Edit the `Brewfile` by hand. Put each new package in the right section, with a short comment.

Do not use `brew bundle dump`. It rewrites the file and removes the sections and comments.

To see what is installed on your Mac but missing from the `Brewfile`:

```bash
brew bundle cleanup         # only shows the list, removes nothing
```

To check that every package in the `Brewfile` still exists in Homebrew:

```bash
scripts/validate-brewfile.sh
```

[GitHub Actions](.github/workflows/validate.yml) runs this check on every push, on every pull request and every Monday, on both Apple Silicon and Intel. It also checks the shell scripts and the links in this README.

## Contributing

Ideas are welcome. Open an issue or a pull request.

## License

[MIT](LICENSE). You can use, copy and change this project freely.
