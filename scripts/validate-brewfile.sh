#!/usr/bin/env bash
#
# Check that every package in the Brewfile can still be installed.
# Homebrew and the App Store sometimes remove or disable packages,
# and then `brew bundle install` fails for that package.
#
# Usage: scripts/validate-brewfile.sh

set -euo pipefail # stop at the first error

cd "$(dirname "$0")/.." # go to the repo root, where the Brewfile is
brew update --quiet     # get Homebrew's newest package list
unset HOMEBREW_BREWORK_CLI_ONLY # always check both lists,
export HOMEBREW_BREWORK_REMOTE_DESKTOP=1 # and the apps that only install.sh --remote-desktop installs

missing=0

# Read the package names from the Brewfile.
# This also fails if the Brewfile has a typo in it.
formulas="$(brew bundle list --formula)"
casks="$(brew bundle list --cask)"
app_store_ids="$(grep -h '^mas ' Brewfile Brewfile.apps | sed 's/.*id: *\([0-9]*\).*/\1/')"

# 1. CLI tools (brew "..."): they must exist and not be disabled.
for name in $formulas; do
  if brew info --json=v2 --formula "$name" 2>/dev/null | jq -e '.formulae[0].disabled == false' >/dev/null; then
    echo "ok       $name"
  else
    echo "MISSING  $name (removed or disabled)"
    missing=$((missing + 1))
  fi
done

# 2. Apps (cask "..."): they must exist and not be disabled.
for name in $casks; do
  if brew info --json=v2 --cask "$name" 2>/dev/null | jq -e '.casks[0].disabled == false' >/dev/null; then
    echo "ok       $name"
  else
    echo "MISSING  $name (removed or disabled)"
    missing=$((missing + 1))
  fi
done

# 3. App Store apps (mas "...", id: ...): they must exist and run on a Mac.
# Apple's public search API knows every app by its id. No sign-in needed.
# An app that needs a newer macOS than 15 must have that version in the README
# (Troubleshooting), so the README does not go out of date when Apple updates the app.
# entity=desktopSoftware: for an app on both iPhone and Mac (like WhatsApp), get the Mac
# version. Without it, Apple returns the iPhone app and its iOS version.
for id in $app_store_ids; do
  # One failed lookup is counted, and the other checks still run.
  if ! app="$(curl -fsS "https://itunes.apple.com/lookup?id=$id&entity=desktopSoftware" | jq '.results[0] // {}')"; then
    echo "MISSING  App Store id $id (could not reach Apple's lookup API: run again later)"
    missing=$((missing + 1))
    continue
  fi
  if ! echo "$app" | jq -e '.kind == "mac-software" or (.supportedDevices // [] | any(startswith("MacDesktop")))' >/dev/null; then
    echo "MISSING  App Store id $id (no Mac app with this id)"
    missing=$((missing + 1))
    continue
  fi
  name="$(echo "$app" | jq -r '.trackName')"
  min_macos="$(echo "$app" | jq -r '.minimumOsVersion')"
  if awk -v v="$min_macos" 'BEGIN { split(v, a, "."); exit !(a[1] > 15 || (a[1] == 15 && a[2] + a[3] > 0)) }' &&
    ! grep -qwF "macOS $min_macos" README.md; then
    echo "MISSING  macOS $min_macos in README.md ($name needs it now: update Troubleshooting)"
    missing=$((missing + 1))
  else
    echo "ok       App Store id $id"
  fi
done

# 4. The tools that install.sh installs with mise (MISE_TOOLS): each version must still exist.
command -v mise >/dev/null || brew install --quiet mise
mise_tools="$(sed -n 's/^MISE_TOOLS="\([^"]*\)".*/\1/p' install.sh)"
for tool in $mise_tools; do
  # Not `mise ls-remote | grep -q`: grep stops early, mise gets a broken pipe, and pipefail fails the check.
  if grep -qxF "${tool#*@}" <<<"$(mise ls-remote "${tool%@*}" 2>/dev/null)"; then
    echo "ok       $tool (mise)"
    # A newer version does not fail the check. On GitHub it shows as a warning on the run.
    latest="$(mise latest "${tool%@*}" 2>/dev/null || true)" # a failed lookup is no warning, not an error
    if [ -n "$latest" ] && [ "$latest" != "${tool#*@}" ]; then
      echo "NEWER    ${tool%@*} $latest is out. Update MISE_TOOLS in install.sh"
      if [ -n "${GITHUB_ACTIONS:-}" ]; then
        echo "::warning title=Update MISE_TOOLS::${tool%@*} $latest is out (install.sh has ${tool#*@})"
      fi
    fi
  else
    echo "MISSING  $tool (mise cannot find this version)"
    missing=$((missing + 1))
  fi
done

echo
echo "$missing missing"
[ "$missing" -eq 0 ] # fail the check if anything is missing
