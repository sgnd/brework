# Security

`install.sh` runs on your Mac and asks for your password, so security problems matter here.

## Report a problem

Please don't open a public issue for a security problem. Report it privately instead:

1. Open the [Security tab](https://github.com/sgnd/masbrew/security) of this repo.
2. Click **Report a vulnerability**.

You get an answer within a week. Once it is fixed, a new release says what changed.

## What counts

- A way to make `install.sh`, `scripts/smoke-test.sh` or `scripts/validate-brewfile.sh` do something it should not (for example, run other code or change files outside what the README says).
- A package in the `Brewfile` or `Brewfile.apps` that is not what it says it is.

A security problem in one of the tools themselves (like `docker` or `gh`) belongs to that project. Report it there.

## Supported versions

Only the newest release and `main` get fixes. The install command always uses `main`.
