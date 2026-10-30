# Brewfile: tools and apps for a Dev & Ops Mac
# Install everything with: brew bundle install
# Docs: https://docs.brew.sh/Brew-Bundle-and-Brewfile

# ============================================================================
# CLI tools
# ============================================================================

# ----------------------------------------------------------------------------
# Version control
# ----------------------------------------------------------------------------
brew "git"                # Version control
brew "gh"                 # GitHub from the terminal
brew "git-delta"          # Colored, easy-to-read git diffs

# ----------------------------------------------------------------------------
# Code quality & Git hooks
# ----------------------------------------------------------------------------
brew "pre-commit"         # Run checks before each git commit
brew "shellcheck"         # Find bugs in shell scripts
brew "hadolint"           # Find mistakes in Dockerfiles

# ----------------------------------------------------------------------------
# Security & secrets
# ----------------------------------------------------------------------------
brew "age"                # Simple file encryption
brew "sops"               # Keep secrets encrypted in git
brew "gitleaks"           # Find leaked passwords and keys in git
brew "trivy"              # Find security issues in images and code

# ----------------------------------------------------------------------------
# Cloud CLIs
# ----------------------------------------------------------------------------
brew "awscli"             # AWS from the terminal
brew "doctl"              # DigitalOcean from the terminal
brew "supabase"           # Supabase from the terminal

# ----------------------------------------------------------------------------
# Infrastructure as Code & server setup
# ----------------------------------------------------------------------------
brew "opentofu"           # Open-source Terraform
brew "ansible"            # Set up and update servers automatically
brew "ansible-lint"       # Find mistakes in Ansible playbooks

# ----------------------------------------------------------------------------
# Containers
# ----------------------------------------------------------------------------
brew "colima"             # Runs the Docker engine on your Mac
brew "docker"             # Docker commands
brew "docker-compose"     # Run multi-container apps (docker compose)
brew "docker-buildx"      # Build images (docker buildx)

# ----------------------------------------------------------------------------
# Kubernetes
# ----------------------------------------------------------------------------
brew "kubernetes-cli"     # Kubernetes from the terminal (kubectl)
brew "helm"               # Install apps on Kubernetes
brew "kustomize"          # Change Kubernetes YAML without templates
brew "kubectx"            # Switch Kubernetes clusters and namespaces
brew "stern"              # Follow logs from many pods at once

# ----------------------------------------------------------------------------
# JSON, YAML & HTTP
# ----------------------------------------------------------------------------
brew "jq"                 # Read and edit JSON
brew "yq"                 # Read and edit YAML
brew "httpie"             # Simple HTTP requests

# ----------------------------------------------------------------------------
# Languages & environment
# ----------------------------------------------------------------------------
brew "mise"               # Install Node, Python, Go, ... per project
brew "direnv"             # Load env variables per folder

# ----------------------------------------------------------------------------
# Shell & CLI utilities
# ----------------------------------------------------------------------------
brew "zoxide"             # Smarter cd: jump to folders you use often
brew "fzf"                # Search lists as you type
brew "ripgrep"            # Fast text search in files (rg)
brew "fd"                 # Fast file search
brew "bat"                # cat with colors
brew "eza"                # ls with colors and icons
brew "tree"               # Show folders as a tree
brew "tlrc"               # Short help with examples (tldr)
brew "watch"              # Run a command every few seconds
brew "wget"               # Download files
brew "rsync"              # Copy and sync files (newer than the macOS one)

# ----------------------------------------------------------------------------
# System maintenance
# ----------------------------------------------------------------------------
brew "mole"               # Clean up your Mac
brew "mas"                # Install App Store apps from the terminal

# ============================================================================
# Apps
# ============================================================================

# ----------------------------------------------------------------------------
# Editors & terminals
# ----------------------------------------------------------------------------
cask "visual-studio-code" # Code editor
cask "cursor"             # AI code editor
cask "warp"               # Terminal

# ----------------------------------------------------------------------------
# AI assistants
# ----------------------------------------------------------------------------
cask "claude"             # Claude desktop app
cask "chatgpt"            # ChatGPT desktop app
cask "copilot-cli"        # GitHub Copilot in the terminal

# ----------------------------------------------------------------------------
# Networking & VPN
# ----------------------------------------------------------------------------
cask "cloudflare-warp"    # Cloudflare VPN
cask "openvpn-connect"    # OpenVPN

# ----------------------------------------------------------------------------
# Browsers
# ----------------------------------------------------------------------------
cask "google-chrome"      # Web browser

# ----------------------------------------------------------------------------
# Fonts
# ----------------------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font" # Coding font with icons

# ============================================================================
# Mac App Store (sign in to the App Store first)
# ============================================================================
mas "Xcode", id: 497799835                       # Apple developer tools
mas "Termius", id: 1176074088                    # SSH client
mas "Telegram", id: 747648890                    # Messaging app
mas "WhatsApp Messenger", id: 310633997          # Messaging app
mas "WeChat", id: 836500024                      # Messaging app
