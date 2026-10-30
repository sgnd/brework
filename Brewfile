# Brewfile — macOS workstation setup for Dev & Ops
# Install everything with: brew bundle install
# https://github.com/Homebrew/homebrew-bundle

# ============================================================================
# CLI tools
# ============================================================================

# ----------------------------------------------------------------------------
# Version control
# ----------------------------------------------------------------------------
brew "git"                # Distributed revision control system
brew "gh"                 # GitHub command-line tool
brew "git-delta"          # Syntax-highlighting pager for git and diff output

# ----------------------------------------------------------------------------
# Code quality & Git hooks
# ----------------------------------------------------------------------------
brew "pre-commit"         # Framework for managing multi-language pre-commit hooks
brew "shellcheck"         # Static analysis and lint tool for (ba)sh scripts
brew "hadolint"           # Dockerfile linter

# ----------------------------------------------------------------------------
# Security & secrets
# ----------------------------------------------------------------------------
brew "age"                # Simple, modern, secure file encryption
brew "sops"               # Editor of encrypted files
brew "gitleaks"           # Audit git repos for secrets
brew "trivy"              # Vulnerability scanner for images, file systems and repos

# ----------------------------------------------------------------------------
# Cloud CLIs
# ----------------------------------------------------------------------------
brew "awscli"             # Official Amazon AWS command-line interface
brew "doctl"              # DigitalOcean command-line tool
brew "supabase"           # Supabase (Postgres development platform) CLI

# ----------------------------------------------------------------------------
# Infrastructure as Code & configuration management
# ----------------------------------------------------------------------------
brew "opentofu"           # Open-source drop-in replacement for Terraform
brew "ansible"            # Automate deployment, configuration and upgrades
brew "ansible-lint"       # Best-practice checker for Ansible playbooks

# ----------------------------------------------------------------------------
# Containers
# ----------------------------------------------------------------------------
brew "colima"             # Lightweight container runtime (Docker engine in a VM)
brew "docker"             # Docker CLI
brew "docker-compose"     # Multi-container apps (`docker compose`)
brew "docker-buildx"      # BuildKit builder (`docker buildx`)

# ----------------------------------------------------------------------------
# Kubernetes
# ----------------------------------------------------------------------------
brew "kubernetes-cli"     # kubectl
brew "helm"               # Kubernetes package manager
brew "kustomize"          # Template-free customization of Kubernetes YAML
brew "kubectx"            # Switch between kubectl contexts and namespaces
brew "stern"              # Tail logs from multiple pods and containers

# ----------------------------------------------------------------------------
# Data processing & HTTP
# ----------------------------------------------------------------------------
brew "jq"                 # Command-line JSON processor
brew "yq"                 # Process YAML, JSON, XML, CSV and properties files
brew "httpie"             # User-friendly command-line HTTP client

# ----------------------------------------------------------------------------
# Runtime & environment management
# ----------------------------------------------------------------------------
brew "mise"               # Polyglot runtime manager (Node, Python, Go, ...)
brew "direnv"             # Load/unload environment variables per directory

# ----------------------------------------------------------------------------
# Shell & CLI utilities
# ----------------------------------------------------------------------------
brew "zoxide"             # Smarter cd that learns your most-used directories
brew "fzf"                # Command-line fuzzy finder
brew "ripgrep"            # Fast recursive search (rg)
brew "fd"                 # Simple, fast alternative to find
brew "bat"                # cat with syntax highlighting and Git integration
brew "eza"                # Modern replacement for ls
brew "tree"               # Display directories as trees
brew "tlrc"               # tldr client: simplified, example-based man pages
brew "watch"              # Run a program periodically, showing output fullscreen
brew "wget"               # Internet file retriever

# ----------------------------------------------------------------------------
# System maintenance
# ----------------------------------------------------------------------------
brew "mole"               # Deep clean and optimize your Mac
brew "mas"                # Mac App Store command-line interface

# ============================================================================
# Apps
# ============================================================================

# ----------------------------------------------------------------------------
# Editors & terminals
# ----------------------------------------------------------------------------
cask "visual-studio-code" # Code editor
cask "cursor"             # AI-first code editor
cask "warp"               # Modern terminal
cask "termius"            # SSH client

# ----------------------------------------------------------------------------
# AI assistants
# ----------------------------------------------------------------------------
cask "claude"             # Claude desktop app
cask "chatgpt"            # ChatGPT desktop app
cask "copilot-cli"        # GitHub Copilot coding agent in the terminal

# ----------------------------------------------------------------------------
# Networking & VPN
# ----------------------------------------------------------------------------
cask "cloudflare-warp"    # Cloudflare WARP client
cask "openvpn-connect"    # OpenVPN client

# ----------------------------------------------------------------------------
# Browsers
# ----------------------------------------------------------------------------
cask "google-chrome"      # Web browser

# ----------------------------------------------------------------------------
# Communication
# ----------------------------------------------------------------------------
cask "telegram"           # Messaging app
cask "whatsapp"           # Messaging app
cask "wechat"             # Messaging app

# ----------------------------------------------------------------------------
# Fonts
# ----------------------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font" # Programming font with Nerd Font icons

# ============================================================================
# Mac App Store (requires signing in to the App Store first)
# ============================================================================
mas "Xcode", id: 497799835
