#!/usr/bin/env bash
#
# Bootstrap a macOS workstation from this repository's Brewfile:
# install Homebrew, put it on PATH, clone this repository and run `brew bundle`.
#
#   curl -fsSL https://raw.githubusercontent.com/sgnd/brew/main/install.sh | bash
#
# Kept compatible with the bash 3.2 that ships with macOS.

set -euo pipefail

REPO_URL="https://github.com/sgnd/brew.git"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

usage() {
  cat <<'EOF'
Usage: install.sh [--check]

Install Homebrew (if needed) and every package in the Brewfile.

Options:
  --check     Only report which packages are missing; install nothing.
  -h, --help  Show this help.

Environment:
  BREW_REPO_DIR  Where to clone this repository when the script is not run
                 from a checkout (default: ~/brew).
EOF
}

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

brew_bin() {
  if [ "$(uname -m)" = "arm64" ]; then
    echo /opt/homebrew/bin/brew
  else
    echo /usr/local/bin/brew
  fi
}

install_homebrew() {
  if [ -x "$(brew_bin)" ]; then
    log "Homebrew is already installed"
    return
  fi

  log "Installing Homebrew"
  local installer
  installer="$(curl -fsSL "$HOMEBREW_INSTALL_URL")"
  # When piped through `curl | bash`, stdin is the pipe, so give the
  # installer the terminal to ask for confirmation and the sudo password.
  if (: </dev/tty) 2>/dev/null; then
    /bin/bash -c "$installer" </dev/tty
  else
    NONINTERACTIVE=1 /bin/bash -c "$installer"
  fi
}

load_shellenv() {
  local brew
  brew="$(brew_bin)"
  [ -x "$brew" ] || die "Homebrew is not installed (expected $brew)"
  eval "$("$brew" shellenv)"
}

persist_shellenv() {
  local zprofile="$HOME/.zprofile"
  if grep -qs "brew shellenv" "$zprofile"; then
    return
  fi
  log "Adding Homebrew to PATH in $zprofile"
  # shellcheck disable=SC2016 # $(...) is written literally, for the login shell to run
  printf '\neval "$(%s shellenv)"\n' "$(brew_bin)" >>"$zprofile"
}

# Sets REPO_DIR to the checkout that holds the Brewfile, cloning it if needed.
find_repo() {
  local script_path="${BASH_SOURCE[0]:-}"
  if [ -n "$script_path" ] && [ -f "$script_path" ]; then
    local script_dir
    script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    if [ -f "$script_dir/Brewfile" ]; then
      REPO_DIR="$script_dir"
      log "Using Brewfile in $REPO_DIR"
      return
    fi
  fi

  REPO_DIR="${BREW_REPO_DIR:-$HOME/brew}"
  if [ -d "$REPO_DIR/.git" ]; then
    log "Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || log "Could not update $REPO_DIR; using it as is"
  elif [ -e "$REPO_DIR" ]; then
    die "$REPO_DIR exists but is not a git checkout; set BREW_REPO_DIR to another path"
  else
    log "Cloning $REPO_URL into $REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
  fi
}

main() {
  local check_only=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --check) check_only=1 ;;
      -h | --help) usage; exit 0 ;;
      *) die "Unknown option: $1 (see --help)" ;;
    esac
    shift
  done

  [ "$(uname -s)" = "Darwin" ] || die "This script only supports macOS"

  if [ "$check_only" -eq 0 ]; then
    install_homebrew
  fi
  load_shellenv
  if [ "$check_only" -eq 0 ]; then
    persist_shellenv
  fi

  find_repo
  local brewfile="$REPO_DIR/Brewfile"

  if [ "$check_only" -eq 1 ]; then
    log "Checking $brewfile"
    brew bundle check --verbose --file="$brewfile"
    return
  fi

  if grep -q '^mas ' "$brewfile"; then
    log "Mac App Store apps are included: make sure you are signed in to the App Store"
  fi
  log "Installing packages from $brewfile"
  brew bundle install --file="$brewfile"
  log "Done. Open a new terminal to pick up the updated PATH."
}

# Everything runs from main so that `curl | bash` only starts once the whole
# script has been downloaded.
main "$@"
