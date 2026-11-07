#!/usr/bin/env bash
#
# brework installer
#
# Sets up a Mac with the tools in the Brewfile and the apps in Brewfile.apps:
#   1. Install Homebrew (if you don't have it yet)
#   2. Add Homebrew to your PATH, for every shell (zsh and bash)
#   3. Find the Brewfile (download this repo if needed)
#   4. Install everything in the Brewfile and Brewfile.apps (only the Brewfile with --cli-only), and MISE_TOOLS with mise
#   5. Set up docker compose and docker buildx
#   6. Turn on the shell tools (mise, direnv, zoxide, fzf) and delta for git,
#      and add the mise tools to your PATH, for every shell
#   7. Start Docker (Colima) now and every time you log in
#
# Run it with:
#   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash
# or from a downloaded copy of this repo:
#   ./install.sh
#
# Only the CLI tools, without the GUI and App Store apps (Brewfile.apps):
#   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash -s -- --cli-only
#   ./install.sh --cli-only
#
# Show the help: ./install.sh --help
#
# You can run it again at any time. It installs what is missing and updates what is out of date.

set -euo pipefail # stop at the first error

# Forked this repo? Put your fork's address here, so the script installs your list.
REPO_URL="https://github.com/sgnd/brework.git"
REPO_DIR="$HOME/.brework" # where `curl | bash` downloads this repo
# Installed with mise, at these versions: the official Apple Silicon builds.
# usql is not in Homebrew core. Homebrew's mongosh needs its own Node.js, next to the one from mise.
MISE_TOOLS="usql@0.21.6 mongosh@2.14.1"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
step() { printf '\n\033[1;32mStep %s of 7:\033[0m \033[1m%s\033[0m\n' "$1" "$2"; } # a header, so you can see how far it is
fail() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# Not read from this file's header: with `curl | bash` there is no file.
usage() {
  cat <<'EOF'
brework installer: sets up this Mac with the tools in the Brewfile and the apps in Brewfile.apps.

Usage:
  curl -fsSL https://raw.githubusercontent.com/sgnd/brework/main/install.sh | bash
  ./install.sh               # tools and apps
  ./install.sh --cli-only    # only the command-line tools, without the apps
  ./install.sh --help        # show this help

You can run it again at any time. It installs what is missing and updates what is out of date.
More: https://github.com/sgnd/brework
EOF
}

# Add a line to a file, unless a line with this keyword is already there.
# If the file does not end with a new line (some editors save it that way),
# start one first, so our line is not glued to your last line.
# Usage: add_line FILE KEYWORD LINE
add_line() {
  grep -qsF "$2" "$1" && return
  [ ! -s "$1" ] || [ -z "$(tail -c 1 "$1")" ] || echo >>"$1"
  echo "$3" >>"$1"
}

main() {
  # --- 0. Read the option and check this Mac -------------------------------

  # --cli-only skips Brewfile.apps. The Brewfile reads this setting.
  [ $# -le 1 ] || fail "Too many options. Use --cli-only, or none. See: install.sh --help"
  case "${1:-}" in
    "") ;;
    --cli-only) export HOMEBREW_BREWORK_CLI_ONLY=1 ;;
    -h | --help) usage; exit 0 ;;
    *) fail "Unknown option: $1. Use --cli-only, or none. See: install.sh --help" ;;
  esac

  [ "$(uname -s)" = "Darwin" ] || fail "brework only works on macOS."

  # Homebrew no longer installs on Intel Macs.
  if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" != "1" ]; then
    fail "brework needs a Mac with Apple Silicon (M1 or newer). Homebrew no longer installs on Intel Macs."
  fi

  # A Rosetta (Intel mode) terminal would install the wrong Homebrew.
  if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
    fail "This terminal runs in Rosetta (Intel mode). Open a normal terminal and try again."
  fi

  # The tools and apps in the lists need macOS 15 or newer (see the README).
  macos_major="$(sw_vers -productVersion | cut -d. -f1)"
  [ "$macos_major" -ge 15 ] 2>/dev/null || fail "brework needs macOS 15 or newer. Update macOS in System Settings > General > Software Update."

  BREW=/opt/homebrew/bin/brew # where Homebrew lives on Apple Silicon

  # --- 1. Install Homebrew -------------------------------------------------

  step 1 "Homebrew"
  if [ -x "$BREW" ]; then
    say "Homebrew is already installed."
  else
    say "Installing Homebrew..."
    homebrew_failed="Homebrew did not install. Read the lines above, then run this script again from a Terminal window."
    installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || fail "$homebrew_failed"
    # With `curl | bash` the keyboard is not connected to this script.
    # Connect the Homebrew installer to the terminal so it can ask for your password.
    if (: </dev/tty) 2>/dev/null; then
      /bin/bash -c "$installer" </dev/tty || fail "$homebrew_failed"
    else
      NONINTERACTIVE=1 /bin/bash -c "$installer" || fail "$homebrew_failed"
    fi
  fi

  # --- 2. Add Homebrew to your PATH ----------------------------------------

  step 2 "Add Homebrew to your PATH"
  eval "$("$BREW" shellenv)" # for the rest of this script

  # Every zsh reads ~/.zshenv: a terminal, an IDE, an AI agent, a script, `ssh mac COMMAND`.
  # A login shell (a terminal, most IDEs and agents) then lets macOS put /usr/bin first again,
  # so ~/.zprofile needs the same line. bash reads ~/.bash_profile (and then skips ~/.profile).
  say "Adding Homebrew to your PATH in ~/.zshenv, ~/.zprofile and ~/.bash_profile"
  # bash reads only the first of ~/.bash_profile, ~/.bash_login and ~/.profile.
  # A new ~/.bash_profile loads the one bash read before.
  if [ ! -f "$HOME/.bash_profile" ]; then
    for old in .bash_login .profile; do
      if [ -f "$HOME/$old" ]; then
        echo ". \"\$HOME/$old\" # added by brework, so bash still reads ~/$old" >"$HOME/.bash_profile"
        break
      fi
    done
  fi
  # The keyword is the full Apple Silicon path: an old line for an Intel Homebrew
  # (/usr/local/bin/brew, for example after Migration Assistant) must not stop this one.
  add_line "$HOME/.zshenv" "$BREW shellenv" "eval \"\$($BREW shellenv)\" # added by brework"
  add_line "$HOME/.zprofile" "$BREW shellenv" "eval \"\$($BREW shellenv)\" # added by brework"
  add_line "$HOME/.bash_profile" "$BREW shellenv" "eval \"\$($BREW shellenv bash)\" # added by brework"

  # --- 3. Find the Brewfile ------------------------------------------------

  update_failed=no
  step 3 "Get the list"
  # With `curl | bash` there is no install.sh file, so this is skipped.
  if [ "$(basename "${BASH_SOURCE[0]:-}")" = install.sh ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/Brewfile" ]; then
    # You ran ./install.sh from a downloaded copy: use its Brewfile.
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    say "Using the list in $REPO_DIR"
  elif [ -d "$REPO_DIR" ]; then
    say "Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || { say "Could not update. Using the copy you have."; update_failed=yes; }
  else
    say "Downloading brework to $REPO_DIR"
    # git needs Apple's Command Line Tools. A macOS update can remove them.
    xcode-select -p >/dev/null 2>&1 || fail "Install Apple's Command Line Tools with: xcode-select --install. Then run this script again."
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  [ -f "$REPO_DIR/Brewfile" ] || fail "No Brewfile in $REPO_DIR. Delete that folder and run again."

  # An old Brewfile (from before Brewfile.apps) would install the apps anyway.
  if [ "${HOMEBREW_BREWORK_CLI_ONLY:-}" = 1 ] && ! grep -q HOMEBREW_BREWORK_CLI_ONLY "$REPO_DIR/Brewfile"; then
    fail "The Brewfile in $REPO_DIR does not support --cli-only. Update it with: git -C $REPO_DIR pull"
  fi

  # --- 4. Install everything in the Brewfile -------------------------------

  step 4 "Install the tools and apps (this takes the longest)"
  say "Installing the list in $REPO_DIR. This can take a while..."
  if [ "${HOMEBREW_BREWORK_CLI_ONLY:-}" = 1 ]; then
    say "Only the CLI tools: the apps in Brewfile.apps are skipped."
  else
    say "App Store apps need you to be signed in to the App Store."
  fi
  # If one package fails, keep going: steps 5 to 7 still run and you get a clear message at the end.
  all_installed=yes
  mise_failed=no
  brew bundle install --file="$REPO_DIR/Brewfile" || all_installed=no

  if command -v mise >/dev/null; then
    say "Installing $MISE_TOOLS with mise"
    # shellcheck disable=SC2086 # one argument per tool
    mise use --global $MISE_TOOLS || { all_installed=no; mise_failed=yes; }
  else
    all_installed=no
    mise_failed=yes
  fi

  # --- 5. Set up docker compose and docker buildx --------------------------

  step 5 "Set up docker compose and docker buildx"
  # Docker looks for its plugins in ~/.docker/cli-plugins.
  # Link the plugins that Homebrew installed into that folder.
  mkdir -p "$HOME/.docker/cli-plugins"
  for plugin in "$(brew --prefix)"/lib/docker/cli-plugins/docker-*; do
    [ -e "$plugin" ] || continue
    ln -sfn "$plugin" "$HOME/.docker/cli-plugins/$(basename "$plugin")"
  done

  # --- 6. Turn on the shell tools and delta for git ------------------------

  step 6 "Set up your shell"
  # mise, direnv, zoxide and fzf need one line in ~/.zshrc to work.
  # Each line checks that the tool is installed, so a removed tool never breaks your terminal.
  say "Turning on mise, direnv, zoxide and fzf in ~/.zshrc"
  # shellcheck disable=SC2016 # these lines run later, in your terminal
  {
    add_line "$HOME/.zshrc" "mise activate" 'command -v mise >/dev/null && eval "$(mise activate zsh)" # added by brework'
    add_line "$HOME/.zshrc" "direnv hook" 'command -v direnv >/dev/null && eval "$(direnv hook zsh)" # added by brework'
    add_line "$HOME/.zshrc" "zoxide init" 'command -v zoxide >/dev/null && eval "$(zoxide init zsh)" # added by brework'
    add_line "$HOME/.zshrc" "fzf --zsh" 'command -v fzf >/dev/null && source <(fzf --zsh) # added by brework'
  }

  # IDEs, AI agents and scripts don't read ~/.zshrc. Without these lines they don't find the mise tools,
  # or they find the wrong ones (like the macOS java). Same files as Homebrew in step 2, for the same reasons.
  say "Adding the mise tools to your PATH in ~/.zshenv, ~/.zprofile and ~/.bash_profile"
  # shellcheck disable=SC2016 # these lines run later, in your shell
  {
    add_line "$HOME/.zshenv" "mise activate zsh --shims" 'command -v mise >/dev/null && eval "$(mise activate zsh --shims)" # added by brework'
    add_line "$HOME/.zprofile" "mise activate zsh --shims" 'command -v mise >/dev/null && eval "$(mise activate zsh --shims)" # added by brework'
    add_line "$HOME/.bash_profile" "mise activate bash --shims" 'command -v mise >/dev/null && eval "$(mise activate bash --shims)" # added by brework'
  }

  # Show git diffs with delta, unless you already picked a pager for git.
  if command -v delta >/dev/null && [ -z "$(git config --global --includes core.pager)" ]; then
    say "Showing git diffs with delta"
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
  fi

  # --- 7. Start Docker (Colima) --------------------------------------------

  step 7 "Start Docker (Colima)"
  # Colima starts now in the background, and again every time you log in.
  # A Colima you already started yourself is left alone, so your containers keep running.
  # Not `brew services list | grep -q`: grep stops early, brew gets a broken pipe, and pipefail fails it.
  if command -v colima >/dev/null && ! grep -q "^colima *started" <<<"$(brew services list)"; then
    if colima status >/dev/null 2>&1; then
      say "Docker (Colima) is already running. To also start it at every login, run: colima stop && brew services start colima"
    else
      say "Starting Docker (Colima) in the background. The first start takes a few minutes."
      brew services start colima || say "Could not start Colima. Start it yourself with: colima start"
    fi
  fi

  if [ "$update_failed" = yes ]; then
    say "Note: $REPO_DIR could not be updated, so this used an older list. See why with: git -C $REPO_DIR status"
  fi

  if [ "$all_installed" = no ]; then
    echo
    # Show only what is missing (or did not update), so you don't have to look for it in the long output above.
    say "Not installed (or not updated):"
    brew bundle check --verbose --file="$REPO_DIR/Brewfile" 2>&1 | grep '→' || true # it prints to stderr
    [ "$mise_failed" = no ] || echo "→ $MISE_TOOLS (with mise: a download may have failed, run this script again)"
    fail "Some packages did not install. Fix them (see https://github.com/sgnd/brework#troubleshooting), then run this script again."
  fi

  check_command="$REPO_DIR/scripts/smoke-test.sh"
  [ "${HOMEBREW_BREWORK_CLI_ONLY:-}" = 1 ] && check_command="$check_command --cli-only"
  echo
  say "Done! Open a new Terminal window (Cmd+N). Wait a few minutes for Docker to start, then check that every tool works:"
  echo "    $check_command"
}

# All the work happens in main(), called on the last line.
# This way `curl | bash` only starts after the whole script has downloaded.
# `exit` on the same line stops bash from reading further, even if this file
# changes while the script runs.
main "$@"; exit
