# Brewfile: CLI tools for a Dev & Ops Mac
# The apps (GUI and App Store) are in Brewfile.apps. This file loads it at the end.
# Install everything with: brew bundle install
#
# How to add something:
#   CLI tool:       brew "name"            find the name with: brew search name
#   GUI app:        put it in Brewfile.apps
#
# Put it in the right section below, with a short comment.
# To remove something, delete its line.
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
brew "git-lfs"            # Keep large files in git

# ----------------------------------------------------------------------------
# Code quality & Git hooks
# ----------------------------------------------------------------------------
brew "pre-commit"         # Run checks before each git commit
brew "shellcheck"         # Find bugs in shell scripts
brew "hadolint"           # Find mistakes in Dockerfiles
brew "shfmt"              # Format shell scripts
brew "actionlint"         # Find mistakes in GitHub Actions workflows

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
brew "docker-credential-helper" # Keep docker login passwords in the macOS keychain
brew "crane"              # Copy and inspect images in a registry, without Docker

# ----------------------------------------------------------------------------
# Kubernetes
# ----------------------------------------------------------------------------
brew "kubernetes-cli"     # Kubernetes from the terminal (kubectl)
brew "helm"               # Install apps on Kubernetes
brew "kustomize"          # Change Kubernetes YAML without templates
brew "kubeconform"        # Check Kubernetes YAML before you apply it
brew "kubectx"            # Switch Kubernetes clusters and namespaces
brew "stern"              # Follow logs from many pods at once

# ----------------------------------------------------------------------------
# JSON, YAML & HTTP
# ----------------------------------------------------------------------------
brew "jq"                 # Read and edit JSON
brew "yq"                 # Read and edit YAML
brew "httpie"             # Simple HTTP requests

# ----------------------------------------------------------------------------
# Database clients
# ----------------------------------------------------------------------------
brew "mongosh"            # MongoDB shell
brew "redis"              # Redis command line (redis-cli)

# ----------------------------------------------------------------------------
# Load testing & benchmarks
# ----------------------------------------------------------------------------
brew "k6"                 # Load test websites and APIs
brew "hyperfine"          # Measure how fast a command runs

# ----------------------------------------------------------------------------
# Languages & environment
# ----------------------------------------------------------------------------
brew "mise"               # Install Node, Python, Go, ... per project
brew "direnv"             # Load env variables per folder
brew "just"               # Save and run project commands (like make)

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
brew "doggo"              # Look up DNS records
brew "rsync"              # Copy and sync files (newer than the macOS one)

# ----------------------------------------------------------------------------
# System maintenance
# ----------------------------------------------------------------------------
brew "mole"               # Clean up your Mac

# ----------------------------------------------------------------------------
# AI in the terminal
# ----------------------------------------------------------------------------
cask "copilot-cli"        # GitHub Copilot in the terminal

# ----------------------------------------------------------------------------
# Fonts
# ----------------------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font" # Coding font with icons (eza shows them)

# ============================================================================
# Apps: the GUI and App Store apps are in Brewfile.apps.
# They are loaded here, unless you install with: install.sh --cli-only
# ============================================================================
instance_eval File.read(File.join(__dir__, "Brewfile.apps")) unless ENV["HOMEBREW_BREWORK_CLI_ONLY"] == "1"
