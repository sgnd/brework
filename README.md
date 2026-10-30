# brew

[![Validate](https://github.com/sgnd/brew/actions/workflows/validate.yml/badge.svg)](https://github.com/sgnd/brew/actions/workflows/validate.yml)

A [Homebrew](https://brew.sh) `Brewfile` for setting up a macOS workstation for Dev & Ops in one command.

## What's inside

Each name links to the project's official site, where you can also download it without Homebrew.

### CLI tools

| Category | Packages |
| --- | --- |
| Version control | [git](https://git-scm.com), [gh](https://cli.github.com), [git-delta](https://dandavison.github.io/delta/), [lazygit](https://github.com/jesseduffield/lazygit) |
| Code quality & Git hooks | [pre-commit](https://pre-commit.com), [shellcheck](https://www.shellcheck.net), [hadolint](https://github.com/hadolint/hadolint) |
| Security & secrets | [age](https://github.com/FiloSottile/age), [sops](https://getsops.io), [gitleaks](https://gitleaks.io), [trivy](https://trivy.dev) |
| Cloud CLIs | [awscli](https://aws.amazon.com/cli/), [doctl](https://docs.digitalocean.com/reference/doctl/), [supabase](https://supabase.com/docs/reference/cli/about) |
| Infrastructure as Code | [opentofu](https://opentofu.org), [ansible](https://www.ansible.com), [ansible-lint](https://docs.ansible.com/projects/lint/) |
| Containers | [dive](https://github.com/wagoodman/dive) (`docker` and `kubectl` come with OrbStack) |
| Kubernetes | [helm](https://helm.sh), [kustomize](https://github.com/kubernetes-sigs/kustomize), [kubectx](https://github.com/ahmetb/kubectx), [k9s](https://k9scli.io), [stern](https://github.com/stern/stern) |
| Data processing & HTTP | [jq](https://jqlang.github.io/jq/), [yq](https://github.com/mikefarah/yq), [httpie](https://httpie.io) |
| Runtime & environment | [mise](https://mise.jdx.dev), [direnv](https://direnv.net) |
| Shell & CLI utilities | [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://junegunn.github.io/fzf/), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [bat](https://github.com/sharkdp/bat), [eza](https://eza.rocks), [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree), [btop](https://github.com/aristocratos/btop), [tlrc](https://tldr.sh/tlrc/), [watch](https://gitlab.com/procps-ng/procps), [wget](https://www.gnu.org/software/wget/) |
| System maintenance | [mole](https://mole.fit), [mas](https://github.com/mas-cli/mas) |

### Apps

| Category | Apps |
| --- | --- |
| Editors & terminals | [Visual Studio Code](https://code.visualstudio.com/download), [Cursor](https://cursor.com/downloads), [Warp](https://www.warp.dev/download), [Termius](https://termius.com/download/macos) |
| Containers & virtualization | [OrbStack](https://orbstack.dev/download) |
| AI assistants | [Claude](https://claude.com/download), [ChatGPT](https://openai.com/chatgpt/download/), [GitHub Copilot CLI](https://github.com/github/copilot-cli/releases) |
| Networking & VPN | [Cloudflare WARP](https://one.one.one.one), [OpenVPN Connect](https://openvpn.net/client/) |
| Browsers | [Google Chrome](https://www.google.com/chrome/) |
| Communication | [Telegram](https://macos.telegram.org), [WhatsApp](https://www.whatsapp.com/download), [WeChat](https://mac.weixin.qq.com) |
| Fonts | [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads) |
| Mac App Store | [Xcode](https://apps.apple.com/app/xcode/id497799835) |

See [`Brewfile`](Brewfile) for a one-line description of each package.

Language runtimes (Node.js, Python, Go, ...) are not installed by Homebrew. They are managed per project with [`mise`](https://mise.jdx.dev).

## Usage

Sign in to the Mac App Store first (needed for Xcode), then run:

```bash
curl -fsSL https://raw.githubusercontent.com/sgnd/brew/main/install.sh | bash
```

[`install.sh`](install.sh) installs Homebrew if it is missing, adds it to your `PATH` in `~/.zprofile`, clones this repository to `~/brew` (change it with `BREW_REPO_DIR`) and runs `brew bundle install`. It is safe to run again: everything already installed is skipped.

From a clone of this repository you can run it directly:

```bash
./install.sh           # install everything
./install.sh --check   # only list what is missing
```

### Manual install

1. Install [Homebrew](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Clone this repository and install everything:

   ```bash
   git clone https://github.com/sgnd/brew.git
   cd brew
   brew bundle install
   ```

### Apps already installed outside Homebrew

If an app was installed by dragging it into `/Applications`, `brew bundle install` stops with an "It seems there is already an App" error. Let Homebrew take over the existing app instead of reinstalling it:

```bash
brew install --cask --adopt visual-studio-code
```

## Keeping it up to date

The `Brewfile` is curated by hand and grouped by category, so edit it directly instead of regenerating it with `brew bundle dump` (which would discard the grouping and comments). Add new packages under the matching section.

To list packages installed on your machine that are not in the `Brewfile`:

```bash
brew bundle cleanup
```

Without `--force` this only prints the list; it does not uninstall anything.

Before opening a pull request, check that every package still exists in Homebrew:

```bash
scripts/validate-brewfile.sh
```

The same check runs in [GitHub Actions](.github/workflows/validate.yml) on every push and pull request, and every Monday to catch packages that were renamed, deprecated or removed upstream. The workflow also runs ShellCheck and checks the links in this README.

## Contributing

Suggestions are welcome. Open an issue or pull request, and keep each package in the right category with a short comment describing it.

## License

[MIT](LICENSE)
