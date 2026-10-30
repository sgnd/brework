# brew

A [Homebrew](https://brew.sh) `Brewfile` for setting up a macOS workstation for Dev & Ops in one command.

## What's inside

### CLI tools

| Category | Packages |
| --- | --- |
| Version control | `git`, `gh`, `git-delta`, `lazygit` |
| Code quality & Git hooks | `pre-commit`, `shellcheck`, `hadolint` |
| Security & secrets | `age`, `sops`, `gitleaks`, `trivy` |
| Cloud CLIs | `awscli`, `doctl`, `supabase` |
| Infrastructure as Code | `opentofu`, `ansible`, `ansible-lint` |
| Containers | `dive` (`docker` and `kubectl` come with OrbStack) |
| Kubernetes | `helm`, `kustomize`, `kubectx`, `k9s`, `stern` |
| Data processing & HTTP | `jq`, `yq`, `httpie` |
| Runtime & environment | `mise`, `direnv` |
| Shell & CLI utilities | `zoxide`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `tree`, `btop`, `tlrc`, `watch`, `wget` |
| System maintenance | `mole`, `mas` |

### Apps

| Category | Apps |
| --- | --- |
| Editors & terminals | Visual Studio Code, Cursor, Warp, Termius |
| Containers & virtualization | OrbStack |
| AI assistants | Claude, ChatGPT, GitHub Copilot CLI |
| Networking & VPN | Cloudflare WARP, OpenVPN Connect |
| Browsers | Google Chrome |
| Communication | Telegram, WhatsApp, WeChat |
| Fonts | JetBrains Mono Nerd Font |
| Mac App Store | Xcode |

See [`Brewfile`](Brewfile) for a one-line description of each package.

Language runtimes (Node.js, Python, Go, ...) are not installed by Homebrew. They are managed per project with [`mise`](https://mise.jdx.dev).

## Usage

1. Install Homebrew:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Sign in to the Mac App Store (needed for Xcode).

3. Clone this repository:

   ```bash
   git clone https://github.com/sgnd/brew.git
   cd brew
   ```

4. Install everything:

   ```bash
   brew bundle install
   ```

Check what is missing without installing anything:

```bash
brew bundle check --verbose
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

## Contributing

Suggestions are welcome. Open an issue or pull request, and keep each package in the right category with a short comment describing it.
