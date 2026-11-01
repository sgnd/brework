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
unset HOMEBREW_BREWORK_CLI_ONLY # always check both lists

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
# (Requirements), so the README does not go out of date when Apple updates the app.
for id in $app_store_ids; do
  app="$(curl -fsS "https://itunes.apple.com/lookup?id=$id" | jq '.results[0] // {}')"
  if ! echo "$app" | jq -e '.kind == "mac-software" or (.supportedDevices // [] | any(startswith("MacDesktop")))' >/dev/null; then
    echo "MISSING  App Store id $id (no Mac app with this id)"
    missing=$((missing + 1))
    continue
  fi
  name="$(echo "$app" | jq -r '.trackName')"
  min_macos="$(echo "$app" | jq -r '.minimumOsVersion')"
  if awk -v v="$min_macos" 'BEGIN { split(v, a, "."); exit !(a[1] > 15 || (a[1] == 15 && a[2] + a[3] > 0)) }' &&
    ! grep -qwF "$min_macos" README.md; then
    echo "MISSING  macOS $min_macos in README.md ($name needs it now: update Requirements)"
    missing=$((missing + 1))
  else
    echo "ok       App Store id $id"
  fi
done

# 4. usql, which install.sh installs with mise at a fixed version.
usql_version="$(sed -n 's/^USQL_VERSION="\([^"]*\)".*/\1/p' install.sh)"
# mise downloads the official Apple Silicon build from GitHub, so that file must exist.
if curl -fsSIL -o /dev/null "https://github.com/xo/usql/releases/download/v$usql_version/usql-$usql_version-darwin-arm64.tar.bz2"; then
  echo "ok       usql $usql_version (mise)"
else
  echo "MISSING  usql $usql_version (no Apple Silicon build on GitHub)"
  missing=$((missing + 1))
fi

echo
echo "$missing missing"
[ "$missing" -eq 0 ] # fail the check if anything is missing
