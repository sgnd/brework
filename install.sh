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
#
# Run it with:
#   curl -fsSL https://raw.githubusercontent.com/sgnd/masbrew/main/install.sh | bash
# or from a downloaded copy of this repo:
#   ./install.sh
#
# You can run it again at any time. It skips what is already installed.

set -euo pipefail # stop at the first error

REPO_URL="https://github.com/sgnd/masbrew.git"
REPO_DIR="$HOME/masbrew" # where `curl | bash` downloads this repo

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

main() {
  # --- 0. Check this Mac ---------------------------------------------------

  [ "$(uname -s)" = "Darwin" ] || fail "masbrew only works on macOS."

  # Apple Silicon Macs keep Homebrew in /opt/homebrew, Intel Macs in /usr/local.
  if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]; then
    BREW=/opt/homebrew/bin/brew
  else
    BREW=/usr/local/bin/brew
  fi

  # On Apple Silicon, a Rosetta (Intel mode) terminal would install the wrong Homebrew.
  if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
    fail "This terminal runs in Rosetta (Intel mode). Open a normal terminal and try again."
  fi

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
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  [ -f "$REPO_DIR/Brewfile" ] || fail "No Brewfile in $REPO_DIR. Delete that folder and run again."

  # --- 4. Install everything in the Brewfile -------------------------------

  say "Installing everything in $REPO_DIR/Brewfile. This can take a while..."
  say "App Store apps need you to be signed in to the App Store."
  brew bundle install --file="$REPO_DIR/Brewfile"

  # --- 5. Set up docker compose and docker buildx --------------------------

  # Docker looks for its plugins in ~/.docker/cli-plugins.
  # Link the plugins that Homebrew installed into that folder.
  mkdir -p "$HOME/.docker/cli-plugins"
  for plugin in "$(brew --prefix)"/lib/docker/cli-plugins/docker-*; do
    [ -e "$plugin" ] || continue
    ln -sfn "$plugin" "$HOME/.docker/cli-plugins/$(basename "$plugin")"
  done

  say "Done! Open a new terminal, then start Docker with: colima start"
}

# All the work happens in main(), called on the last line.
# This way `curl | bash` only starts after the whole script has downloaded.
main "$@"
