#!/usr/bin/env bash
#
# Check that every package in the Brewfile still exists.
# Homebrew and the App Store sometimes rename or remove packages,
# and then `brew bundle install` fails for that package.
#
# Usage: scripts/validate-brewfile.sh

set -euo pipefail # stop at the first error

cd "$(dirname "$0")/.." # go to the repo root, where the Brewfile is
export HOMEBREW_NO_AUTO_UPDATE=1

missing=0

# Read the package names from the Brewfile.
# This also fails if the Brewfile has a typo in it.
formulas="$(brew bundle list --formula)"
casks="$(brew bundle list --cask)"
app_store_ids="$(grep '^mas ' Brewfile | sed 's/.*id: *\([0-9]*\).*/\1/')"

# 1. CLI tools (brew "...")
for name in $formulas; do
  if brew info --formula "$name" >/dev/null 2>&1; then
    echo "ok       $name"
  else
    echo "MISSING  $name"
    missing=$((missing + 1))
  fi
done

# 2. Apps (cask "...")
for name in $casks; do
  if brew info --cask "$name" >/dev/null 2>&1; then
    echo "ok       $name"
  else
    echo "MISSING  $name"
    missing=$((missing + 1))
  fi
done

# 3. App Store apps (mas "...", id: ...)
# Apple's public search API knows every app by its id. No sign-in needed.
for id in $app_store_ids; do
  if curl -fsS "https://itunes.apple.com/lookup?id=$id" | grep -q '"resultCount":1'; then
    echo "ok       App Store id $id"
  else
    echo "MISSING  App Store id $id"
    missing=$((missing + 1))
  fi
done

echo
echo "$missing missing"
[ "$missing" -eq 0 ] # fail the check if anything is missing
