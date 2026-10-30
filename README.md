# brew

A [Homebrew](https://brew.sh) `Brewfile` for setting up a macOS workstation for DevOps and cloud work in one command.

## What's inside

| Category | Packages |
| --- | --- |
| Version control | `git`, `gh` |
| Code quality & Git hooks | `pre-commit`, `shellcheck` |
| Security & secrets | `age`, `sops`, `gitleaks`, `trivy` |
| Cloud CLIs | `awscli`, `doctl`, `supabase` |
| Infrastructure as Code | `opentofu`, `ansible`, `ansible-lint` |
| Kubernetes | `helm`, `kustomize`, `kubectx`, `stern` |
| Data processing | `jq`, `yq` |
| Runtime management | `mise` |
| Shell & CLI utilities | `zoxide`, `watch`, `wget` |
| System maintenance | `mole` |
| AI assistants | `copilot-cli` (cask) |

See [`Brewfile`](Brewfile) for a one-line description of each package.

## Usage

1. Install Homebrew:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Clone this repository:

   ```bash
   git clone https://github.com/sgnd/brew.git
   cd brew
   ```

3. Install everything:

   ```bash
   brew bundle install
   ```

Check what is missing without installing anything:

```bash
brew bundle check --verbose
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
