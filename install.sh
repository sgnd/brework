#!/usr/bin/env bash
#
# masbrew installer
#
# Sets up a Mac with everything in the Brewfile:
#   1. Install Homebrew (if you don't have it yet)
#   2. Add Homebrew to your PATH
#   3. Find the Brewfile (download this repo if needed)
#   4. Install everything in the Brewfile
#   5. Set up docker compose and docker buildx
#   6. Turn on the shell tools (mise, direnv, zoxide, fzf) and delta for git
#   7. Start Docker (Colima) now and every time you log in
#
# Run it with:
#   curl -fsSL https://raw.githubusercontent.com/sgnd/masbrew/main/install.sh | bash
# or from a downloaded copy of this repo:
#   ./install.sh
#
# Only the CLI tools, without the GUI and App Store apps (Brewfile.apps):
#   curl -fsSL https://raw.githubusercontent.com/sgnd/masbrew/main/install.sh | bash -s -- --cli-only
#   ./install.sh --cli-only
#
# You can run it again at any time. It installs what is missing and updates what is out of date.

set -euo pipefail # stop at the first error

# Forked this repo? Put your fork's address here, so the script installs your list.
REPO_URL="https://github.com/sgnd/masbrew.git"
REPO_DIR="$HOME/masbrew" # where `curl | bash` downloads this repo

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# Add a line to ~/.zshrc, unless a line with this keyword is already there.
# Usage: add_to_zshrc KEYWORD LINE
add_to_zshrc() {
  grep -qsF "$1" "$HOME/.zshrc" || echo "$2" >>"$HOME/.zshrc"
}

main() {
  # --- 0. Read the option and check this Mac -------------------------------

  # --cli-only skips Brewfile.apps. The Brewfile reads this setting.
  [ $# -le 1 ] || fail "Too many options. The only option is --cli-only."
  case "${1:-}" in
    "") ;;
    --cli-only) export HOMEBREW_MASBREW_CLI_ONLY=1 ;;
    *) fail "Unknown option: $1. The only option is --cli-only." ;;
  esac

  [ "$(uname -s)" = "Darwin" ] || fail "masbrew only works on macOS."

  # Homebrew no longer installs on Intel Macs.
  if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" != "1" ]; then
    fail "masbrew needs a Mac with Apple Silicon (M1 or newer). Homebrew no longer installs on Intel Macs."
  fi

  # A Rosetta (Intel mode) terminal would install the wrong Homebrew.
  if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
    fail "This terminal runs in Rosetta (Intel mode). Open a normal terminal and try again."
  fi

  BREW=/opt/homebrew/bin/brew # where Homebrew lives on Apple Silicon

  # --- 1. Install Homebrew -------------------------------------------------

  if [ -x "$BREW" ]; then
    say "Homebrew is already installed."
  else
    say "Installing Homebrew..."
    installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # With `curl | bash` the keyboard is not connected to this script.
    # Connect the Homebrew installer to the terminal so it can ask for your password.
    if (: </dev/tty) 2>/dev/null; then
      /bin/bash -c "$installer" </dev/tty
    else
      NONINTERACTIVE=1 /bin/bash -c "$installer"
    fi
  fi

  # --- 2. Add Homebrew to your PATH ----------------------------------------

  eval "$("$BREW" shellenv)" # for the rest of this script

  if ! grep -qs "brew shellenv" "$HOME/.zprofile"; then # for every new terminal
    say "Adding Homebrew to your PATH in ~/.zprofile"
    echo "eval \"\$($BREW shellenv)\"" >>"$HOME/.zprofile"
  fi

  # --- 3. Find the Brewfile ------------------------------------------------

  if [ -f "${BASH_SOURCE[0]:-}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/Brewfile" ]; then
    # You ran ./install.sh from a downloaded copy: use its Brewfile.
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  elif [ -d "$REPO_DIR" ]; then
    say "Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || say "Could not update. Using the copy you have."
  else
    say "Downloading masbrew to $REPO_DIR"
    # git needs Apple's Command Line Tools. A macOS update can remove them.
    xcode-select -p >/dev/null 2>&1 || fail "Install Apple's Command Line Tools with: xcode-select --install. Then run this script again."
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  [ -f "$REPO_DIR/Brewfile" ] || fail "No Brewfile in $REPO_DIR. Delete that folder and run again."

  # An old Brewfile (from before Brewfile.apps) would install the apps anyway.
  if [ "${HOMEBREW_MASBREW_CLI_ONLY:-}" = 1 ] && ! grep -q HOMEBREW_MASBREW_CLI_ONLY "$REPO_DIR/Brewfile"; then
    fail "The Brewfile in $REPO_DIR does not support --cli-only. Update it with: git -C $REPO_DIR pull"
  fi

  # --- 4. Install everything in the Brewfile -------------------------------

  say "Installing the list in $REPO_DIR. This can take a while..."
  if [ "${HOMEBREW_MASBREW_CLI_ONLY:-}" = 1 ]; then
    say "Only the CLI tools: the apps in Brewfile.apps are skipped."
  else
    say "App Store apps need you to be signed in to the App Store."
  fi
  # If one package fails, keep going: steps 5 to 7 still run and you get a clear message at the end.
  all_installed=yes
  brew bundle install --file="$REPO_DIR/Brewfile" || all_installed=no

  # --- 5. Set up docker compose and docker buildx --------------------------

  # Docker looks for its plugins in ~/.docker/cli-plugins.
  # Link the plugins that Homebrew installed into that folder.
  mkdir -p "$HOME/.docker/cli-plugins"
  for plugin in "$(brew --prefix)"/lib/docker/cli-plugins/docker-*; do
    [ -e "$plugin" ] || continue
    ln -sfn "$plugin" "$HOME/.docker/cli-plugins/$(basename "$plugin")"
  done

  # --- 6. Turn on the shell tools and delta for git ------------------------

  # mise, direnv, zoxide and fzf need one line in ~/.zshrc to work.
  # Each line checks that the tool is installed, so a removed tool never breaks your terminal.
  say "Turning on mise, direnv, zoxide and fzf in ~/.zshrc"
  # shellcheck disable=SC2016 # these lines run later, in your terminal
  {
    add_to_zshrc "mise activate" 'command -v mise >/dev/null && eval "$(mise activate zsh)" # added by masbrew'
    add_to_zshrc "direnv hook" 'command -v direnv >/dev/null && eval "$(direnv hook zsh)" # added by masbrew'
    add_to_zshrc "zoxide init" 'command -v zoxide >/dev/null && eval "$(zoxide init zsh)" # added by masbrew'
    add_to_zshrc "fzf --zsh" 'command -v fzf >/dev/null && source <(fzf --zsh) # added by masbrew'
  }

  # Show git diffs with delta, unless you already picked a pager for git.
  if command -v delta >/dev/null && [ -z "$(git config --global --includes core.pager)" ]; then
    say "Showing git diffs with delta"
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
  fi

  # --- 7. Start Docker (Colima) --------------------------------------------

  # Colima starts now in the background, and again every time you log in.
  # A Colima you already started yourself is left alone, so your containers keep running.
  if command -v colima >/dev/null && ! brew services list | grep -q "^colima *started"; then
    if colima status >/dev/null 2>&1; then
      say "Docker (Colima) is already running. To also start it at every login, run: colima stop && brew services start colima"
    else
      say "Starting Docker (Colima) in the background. The first start takes a few minutes."
      brew services start colima || say "Could not start Colima. Start it yourself with: colima start"
    fi
  fi

  if [ "$all_installed" = no ]; then
    fail "Some packages did not install. Read the errors above, fix them, then run this script again."
  fi

  say "Done! Open a new terminal to use everything."
}

# All the work happens in main(), called on the last line.
# This way `curl | bash` only starts after the whole script has downloaded.
# `exit` on the same line stops bash from reading further, even if this file
# changes while the script runs.
main "$@"; exit
