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

errors=0
warnings=0

# check <formula|cask> <name>
check() {
  local kind="$1" name="$2" json status
  if ! json="$(brew info "--$kind" --json=v2 "$name" 2>/dev/null)"; then
    printf 'ERROR    %-6s %s: not found in Homebrew\n' "$kind" "$name"
    errors=$((errors + 1))
    return
  fi

  status="$(jq -r --arg kind "$kind" --arg name "$name" '
    (if $kind == "formula" then .formulae[0] else .casks[0] end) as $p
    | (if $kind == "formula" then $p.name else $p.token end) as $current
    | if $p.disabled then "disabled"
      elif $p.deprecated then "deprecated"
      elif $current != $name and (($p.aliases // []) | index($name) | not) then "renamed to \($current)"
      else "ok" end
  ' <<<"$json")"

  if [ "$status" = "ok" ]; then
    printf 'ok       %-6s %s\n' "$kind" "$name"
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
echo "$errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]
