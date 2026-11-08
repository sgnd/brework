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
# Run it with (the address names the release, the same as BREWORK_VERSION below):
#   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/v1.6.0/install.sh | bash
# or from a downloaded copy of this repo:
#   ./install.sh
#
# Only the CLI tools, without the GUI and App Store apps (Brewfile.apps):
#   curl -fsSL https://raw.githubusercontent.com/sgnd/brework/v1.6.0/install.sh | bash -s -- --cli-only
#   ./install.sh --cli-only
#
# Also TeamViewer and AnyDesk (remote desktop apps, not installed unless you ask):
#   ./install.sh --remote-desktop
#
# Show the help: ./install.sh --help
#
# You can run it again at any time. It installs what is missing and updates what is out of date.
# It keeps the list of the release it is from: a change on GitHub does not reach your Mac by itself.

set -euo pipefail # stop at the first error

# The release this script installs: `curl | bash` puts exactly this tag in REPO_DIR, after a check.
# Each release changes it (see "Make a release" in CONTRIBUTING.md).
# To install a branch or another tag instead, set BREWORK_REF (see docs/advanced.md).
BREWORK_VERSION="v1.6.0"
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
  cat <<EOF
brework installer: sets up this Mac with the tools in the Brewfile and the apps in Brewfile.apps.

Usage:
  curl -fsSL https://raw.githubusercontent.com/sgnd/brework/$BREWORK_VERSION/install.sh | bash
  ./install.sh                    # tools and apps
  ./install.sh --cli-only         # only the command-line tools, without the apps
  ./install.sh --remote-desktop   # also TeamViewer and AnyDesk (remote desktop apps)
  ./install.sh --help             # show this help

This script installs brework $BREWORK_VERSION. You can run it again at any time:
it installs what is missing and updates what is out of date.
To install the main branch instead of a release: BREWORK_REF=main (see the docs first).
More: https://github.com/sgnd/brework
EOF
}

# Add a line to a file, unless a line with this keyword is already there.
# If the file does not end with a new line (some editors save it that way),
# start one first, so our line is not glued to your last line.
# Usage: add_line FILE KEYWORD LINE
add_line() {
  # Lines that are commented out (start with #) do not count.
  # One awk, not `grep -v | grep -q`: with pipefail, the first grep can get SIGPIPE when the
  # second one stops at a match, and a big file would then look as if it had no such line.
  awk -v k="$2" '!/^[[:space:]]*#/ && index($0, k) { f = 1; exit } END { exit !f }' "$1" 2>/dev/null && return
  [ ! -s "$1" ] || [ -z "$(tail -c 1 "$1")" ] || echo >>"$1"
  echo "$3" >>"$1"
}

# Put brework REF (the release in BREWORK_VERSION, or what BREWORK_REF names) in DIR,
# a git copy of this repo, and check it first. Your own changes in DIR are never overwritten.
# Usage: get_brework DIR REF
get_brework() {
  local dir="$1" ref="$2" branch new old got
  # Changed files may be your own list. Stop: don't overwrite them, and don't install a list nobody released.
  if [ -n "$(git -C "$dir" status --porcelain --untracked-files=no)" ]; then
    git -C "$dir" status --short --untracked-files=no
    fail "$dir has changes (above), so it was not updated and nothing from the list was installed. To keep your own list, make it yours: https://github.com/sgnd/brework/blob/main/docs/advanced.md#make-it-yours. To throw the changes away, delete that folder and run this again."
  fi
  # A copy from before v1.6.0 is on the main branch. It moves to the release, unless the branch has commits of yours.
  if git -C "$dir" rev-parse --verify --quiet HEAD >/dev/null && branch="$(git -C "$dir" symbolic-ref --quiet --short HEAD)"; then
    # Empty (not 0) when the branch does not come from GitHub at all.
    if [ "$(git -C "$dir" rev-list --count '@{upstream}..HEAD' 2>/dev/null)" != 0 ]; then
      fail "$dir is on the branch $branch, with commits that are not on GitHub, so it was not updated and nothing from the list was installed. To keep your own list, make it yours: https://github.com/sgnd/brework/blob/main/docs/advanced.md#make-it-yours"
    fi
    say "Moving $dir from the $branch branch to brework $ref"
  fi

  # A release is a tag. Anything else (BREWORK_REF) can be a branch or a tag.
  local refspec="$ref"
  [ "$ref" != "$BREWORK_VERSION" ] || refspec="refs/tags/$ref"
  if ! git -C "$dir" fetch --depth 1 --no-tags origin "$refspec"; then
    git -C "$dir" rev-parse --verify --quiet HEAD >/dev/null || fail "Could not download brework $ref (see the lines above). Check your internet connection, then run this again."
    say "Could not download brework $ref. Using the copy you have: $(git -C "$dir" describe --tags --always)"
    update_failed=yes
    return 0
  fi
  new="$(git -C "$dir" rev-parse 'FETCH_HEAD^{commit}')"

  if [ "$ref" = "$BREWORK_VERSION" ]; then
    # A release never changes. If this Mac already has the tag, GitHub must still have the same one.
    old="$(git -C "$dir" rev-parse --verify --quiet "refs/tags/$ref^{commit}" || true)"
    if [ -n "$old" ] && [ "$old" != "$new" ]; then
      fail "The tag $ref on GitHub is not the $ref this Mac got before (commit $new, not $old). A release never changes, so nothing from the list was installed. Please report it: https://github.com/sgnd/brework/security"
    fi
    # The release is the one this script is from: its install.sh names the same version.
    got="$(git -C "$dir" show "$new:install.sh" 2>/dev/null | sed -n 's/^BREWORK_VERSION="\([^"]*\)".*/\1/p')"
    if [ "$got" != "$ref" ]; then
      fail "The tag $ref on GitHub does not have the install.sh of brework $ref (it says: ${got:-no version}). Nothing from the list was installed. Please report it: https://github.com/sgnd/brework/security"
    fi
    git -C "$dir" update-ref "refs/tags/$ref" FETCH_HEAD # so the check above works next time, and `git describe` shows the version
  fi

  git -C "$dir" checkout --quiet --detach "$new" || fail "Could not switch $dir to brework $ref (see the lines above). Delete that folder and run this again."
  say "Using brework $ref (commit $(git -C "$dir" rev-parse --short HEAD))"
}

main() {
  # --- 0. Read the options and check this Mac ------------------------------

  # --cli-only skips Brewfile.apps. --remote-desktop adds TeamViewer and AnyDesk to it.
  # The Brewfile and Brewfile.apps read these settings.
  for option in "$@"; do
    case "$option" in
      --cli-only) export HOMEBREW_BREWORK_CLI_ONLY=1 ;;
      --remote-desktop) export HOMEBREW_BREWORK_REMOTE_DESKTOP=1 ;;
      -h | --help) usage; exit 0 ;;
      *) fail "Unknown option: $option. Use --cli-only, --remote-desktop, or none. See: install.sh --help" ;;
    esac
  done
  if [ "${HOMEBREW_BREWORK_CLI_ONLY:-}" = 1 ] && [ "${HOMEBREW_BREWORK_REMOTE_DESKTOP:-}" = 1 ]; then
    fail "--remote-desktop adds two apps, and --cli-only skips all apps. Use one of them. See: install.sh --help"
  fi

  # Which brework to download: the release above, unless you set BREWORK_REF (a branch or a tag).
  ref="${BREWORK_REF:-$BREWORK_VERSION}"
  case "$ref" in
    -* | *[!A-Za-z0-9._/-]*) fail "BREWORK_REF must be a branch or a tag, like main or $BREWORK_VERSION. It is: $ref" ;;
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

  BREW=/opt/homebrew/bin/brew # where Homebrew lives on Apple Silicon

  # macOS 15 or newer: older versions are not tested, and many apps in the list need a newer one.
  macos="$(sw_vers -productVersion 2>/dev/null || echo 0)"
  if [ "${macos%%.*}" -lt 15 ] 2>/dev/null; then
    fail "brework needs macOS 15 (Sequoia) or newer. This Mac has macOS $macos. Update it in System Settings > General > Software Update."
  fi

  # Installing Homebrew the first time needs an admin account. Once it is there, it is not needed.
  if [ ! -x "$BREW" ] && ! id -Gn | tr ' ' '\n' | grep -qx admin; then
    fail "Your account is not an admin, and installing Homebrew needs one. Log in as an admin, or ask one to make your account an admin (System Settings > Users & Groups)."
  fi

  # Free disk space: only a warning, because a second run needs much less than a first one.
  need_gb=40
  [ -z "${HOMEBREW_BREWORK_CLI_ONLY:-}" ] || need_gb=20
  free_gb="$(df -g "$HOME" 2>/dev/null | awk 'NR == 2 { print $4 }')"
  if [ -n "$free_gb" ] && [ "$free_gb" -lt "$need_gb" ] 2>/dev/null; then
    say "Warning: only $free_gb GB of free disk space. A first install needs about $need_gb GB. It may stop halfway: free up space if it does (System Settings > General > Storage), then run it again."
  fi

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
    # You ran ./install.sh from a downloaded copy: use its Brewfile, as it is.
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    say "Using the list in $REPO_DIR"
    [ -z "${BREWORK_REF:-}" ] || say "BREWORK_REF is ignored here: ./install.sh does not download or update anything."
  else
    if [ "$ref" != "$BREWORK_VERSION" ]; then
      say "Warning: BREWORK_REF=$ref. This installs $ref instead of the release $BREWORK_VERSION. Only releases are checked, and a branch changes with every merge."
    fi
    if [ -d "$REPO_DIR" ]; then
      say "Updating $REPO_DIR to brework $ref"
      [ -e "$REPO_DIR/.git" ] || fail "$REPO_DIR is not a git copy of brework. Delete that folder and run again."
    else
      say "Downloading brework $ref to $REPO_DIR"
      # git needs Apple's Command Line Tools. A macOS update can remove them.
      xcode-select -p >/dev/null 2>&1 || fail "Install Apple's Command Line Tools with: xcode-select --install. Then run this script again."
      git init --quiet "$REPO_DIR"
      git -C "$REPO_DIR" remote add origin "$REPO_URL"
    fi
    get_brework "$REPO_DIR" "$ref"
  fi

  [ -f "$REPO_DIR/Brewfile" ] || fail "No Brewfile in $REPO_DIR. Delete that folder and run again."

  # An old Brewfile (from before Brewfile.apps) would install the apps anyway.
  if [ "${HOMEBREW_BREWORK_CLI_ONLY:-}" = 1 ] && ! grep -q HOMEBREW_BREWORK_CLI_ONLY "$REPO_DIR/Brewfile"; then
    fail "The Brewfile in $REPO_DIR is too old for --cli-only. Use a newer brework: see https://github.com/sgnd/brework#install"
  fi

  # --- 4. Install everything in the Brewfile -------------------------------

  step 4 "Install the tools and apps (this takes the longest)"
  say "Installing the list in $REPO_DIR. This can take a while..."
  if [ "${HOMEBREW_BREWORK_CLI_ONLY:-}" = 1 ]; then
    say "Only the CLI tools: the apps in Brewfile.apps are skipped."
  else
    say "App Store apps need you to be signed in to the App Store."
    [ "${HOMEBREW_BREWORK_REMOTE_DESKTOP:-}" != 1 ] || say "With the remote desktop apps: TeamViewer and AnyDesk."
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
    say "Note: brework $ref could not be downloaded, so this used the list you already had ($(git -C "$REPO_DIR" describe --tags --always)). Run this again when you are online."
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
