#!/usr/bin/env bash
#
# Check that every formula and cask in a Brewfile still exists in Homebrew,
# and warn about packages that were renamed, deprecated or disabled.
# Mac App Store entries are skipped: checking them needs an App Store account.
#
# Usage: scripts/validate-brewfile.sh [path/to/Brewfile]

set -euo pipefail

brewfile="${1:-Brewfile}"
[ -f "$brewfile" ] || { echo "No such file: $brewfile" >&2; exit 1; }

export HOMEBREW_NO_AUTO_UPDATE=1

# Formulae without a bottle for this CPU are compiled from source: slower,
# but they still install. Homebrew stopped building new Intel bottles.
if [ "$(uname -m)" = "arm64" ]; then arch=arm64; else arch=intel; fi

errors=0
warnings=0
source_builds=0

# check <formula|cask> <name>
check() {
  local kind="$1" name="$2" json status
  if ! json="$(brew info "--$kind" --json=v2 "$name" 2>/dev/null)"; then
    printf 'ERROR    %-6s %s: not found in Homebrew\n' "$kind" "$name"
    errors=$((errors + 1))
    return
  fi

  status="$(jq -r --arg kind "$kind" --arg name "$name" --arg arch "$arch" '
    (if $kind == "formula" then .formulae[0] else .casks[0] end) as $p
    | (if $kind == "formula" then $p.name else $p.token end) as $current
    | ($p.bottle.stable.files // {} | keys) as $tags
    | ($kind == "cask" or ($tags | index("all")) != null
        or any($tags[]; (test("linux") | not) and (startswith("arm64_") == ($arch == "arm64")))) as $bottled
    | if $p.disabled then "disabled"
      elif $p.deprecated then "deprecated"
      elif $current != $name and (($p.aliases // []) | index($name) | not) then "renamed to \($current)"
      elif $bottled | not then "source"
      else "ok" end
  ' <<<"$json")"

  if [ "$status" = "ok" ]; then
    printf 'ok       %-6s %s\n' "$kind" "$name"
  elif [ "$status" = "source" ]; then
    printf 'ok       %-6s %s (no %s bottle: builds from source)\n' "$kind" "$name" "$arch"
    source_builds=$((source_builds + 1))
  else
    printf 'WARNING  %-6s %s: %s\n' "$kind" "$name" "$status"
    warnings=$((warnings + 1))
  fi
}

# `brew bundle list` also fails on Brewfile syntax errors.
formulae="$(brew bundle list --formula --file="$brewfile")"
casks="$(brew bundle list --cask --file="$brewfile")"

for name in $formulae; do check formula "$name"; done
for name in $casks; do check cask "$name"; done

echo
echo "$errors error(s), $warnings warning(s), $source_builds source build(s) on $arch"
[ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]
