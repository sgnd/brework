# Security

`install.sh` runs on your Mac and asks for your password, so security problems matter here.

## Report a problem

Please don't open a public issue for a security problem. Report it privately instead:

1. Open the [Security tab](https://github.com/sgnd/brework/security) of this repo.
2. Click **Report a vulnerability**.

You get an answer within a week. Once it is fixed, a new release (and [CHANGELOG.md](CHANGELOG.md)) says what changed.

## What counts

- A way to make `install.sh`, `scripts/smoke-test.sh` or `scripts/validate-brewfile.sh` do something it should not (for example, run other code or change files outside what the README says).
- A package in the `Brewfile` or `Brewfile.apps` that is not what it says it is.

A security problem in one of the tools themselves (like `docker` or `gh`) belongs to that project. Report it there.

## Supported versions

Only the newest release gets fixes. A fix is on `main` first, and reaches your Mac when you run the install command of the release that has it: each install command installs the one release named in its address. See [Which version you get](docs/advanced.md#which-version-you-get).
