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
for id in $app_store_ids; do
  if curl -fsS "https://itunes.apple.com/lookup?id=$id" |
    jq -e '.results[0] | .kind == "mac-software" or (.supportedDevices // [] | any(startswith("MacDesktop")))' >/dev/null; then
    echo "ok       App Store id $id"
  else
    echo "MISSING  App Store id $id (no Mac app with this id)"
    missing=$((missing + 1))
  fi
done

echo
echo "$missing missing"
[ "$missing" -eq 0 ] # fail the check if anything is missing
