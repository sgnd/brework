## What changes

<!-- One or two lines: what you added, removed or fixed, and why. -->

## Checks

- [ ] `scripts/validate-brewfile.sh` ends with `0 missing`
- [ ] The README tables match the `Brewfile` and `Brewfile.apps`
- [ ] `shellcheck install.sh scripts/*.sh` passes (if you changed a script)
- [ ] `actionlint` passes (if you changed a workflow)
- [ ] The End-to-end check is green (it runs when a Brewfile, `install.sh` or `smoke-test.sh` changes)
- [ ] `CHANGELOG.md` has a line under `Unreleased` (if users notice the change)
