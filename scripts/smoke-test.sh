#!/usr/bin/env bash
#
# Check that the tools really work, not only that they are installed.
# Each check gives a tool one small real task, in a temporary folder.
# No account or sign-in is needed. Tools that need one (gh, aws, ...) only
# show their version.
# It also opens a new terminal and checks that every command is found there.
# Run it in a new terminal, after install.sh.
#
# Usage:
#   scripts/smoke-test.sh              # CLI tools and apps
#   scripts/smoke-test.sh --cli-only   # only the CLI tools
#   SKIP_DOCKER=1 scripts/smoke-test.sh   # when Docker cannot run (like on GitHub)

# No -e: keep going after a failed check.
# No pipefail: some tools exit with an error on purpose (they found the bug we planted),
# and only the last command of a pipe (the grep) should decide.
set -u

cd "$(dirname "$0")/.." || exit 1 # go to the repo root, where the Brewfiles are
repo="$(pwd)"
work="$(mktemp -d)" # every check works in here
trap 'rm -rf "$work"' EXIT
export HOMEBREW_NO_AUTO_UPDATE=1

failed=0

# Run one check: check "what it checks" command...
# Each check runs in its own new folder. Prints ok or FAIL.
# On FAIL, it shows the last lines of the output.
check() {
  local name="$1"
  shift
  local output folder
  folder="$(mktemp -d "$work/check.XXXX")"
  if output="$(cd "$folder" && "$@" 2>&1)"; then
    echo "ok    $name"
  else
    echo "FAIL  $name"
    echo "$output" | tail -5 | sed 's/^/      /'
    failed=$((failed + 1))
  fi
}

# --- Version control -------------------------------------------------------

test_git() {
  export GIT_CONFIG_GLOBAL=/dev/null # ignore your own git settings (like commit signing)
  git init -q repo && cd repo &&
    echo hello >file.txt && git add file.txt &&
    git -c user.name=test -c user.email=test@example.com commit -q -m first &&
    [ "$(git log --oneline | wc -l | tr -d ' ')" = 1 ]
}

test_delta() {
  printf 'old\n' >a.txt && printf 'new\n' >b.txt
  git diff --no-index a.txt b.txt | delta --no-gitconfig | grep -q new
}

# --- Code quality ----------------------------------------------------------

test_pre_commit() {
  pre-commit sample-config >.pre-commit-config.yaml && pre-commit validate-config .pre-commit-config.yaml
}

test_shellcheck() { # must find the missing quotes
  # shellcheck disable=SC2016 # the $1 is the bug we plant
  printf '#!/bin/sh\necho $1\n' >bad.sh
  shellcheck bad.sh | grep -q SC2086
}

test_hadolint() { # must find the :latest tag
  printf 'FROM ubuntu:latest\n' >Dockerfile
  hadolint Dockerfile | grep -q DL3007
}

# --- Security --------------------------------------------------------------

test_age() {
  age-keygen -o key.txt 2>/dev/null &&
    echo secret | age -r "$(age-keygen -y key.txt)" >secret.age &&
    [ "$(age -d -i key.txt secret.age)" = secret ]
}

test_sops() {
  age-keygen -o key.txt 2>/dev/null && echo 'password: hunter2' >secret.yaml &&
    sops --encrypt --age "$(age-keygen -y key.txt)" secret.yaml >secret.enc.yaml &&
    ! grep -q hunter2 secret.enc.yaml &&
    SOPS_AGE_KEY_FILE=key.txt sops --decrypt secret.enc.yaml | grep -q hunter2
}

# A fake GitHub token, made fresh each time.
fake_token() { echo "ghp_$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)"; }

test_gitleaks() { # must find the fake token
  mkdir leak && echo "token = \"$(fake_token)\"" >leak/config.txt
  gitleaks dir --no-banner leak 2>&1 | grep -q 'leaks found: [1-9]'
}

test_trivy() { # must find the fake token (the secret scanner works offline)
  mkdir leak && echo "token = \"$(fake_token)\"" >leak/config.txt
  trivy fs --quiet --skip-version-check --scanners secret leak | grep -qi github
}

# --- Infrastructure as Code ------------------------------------------------

test_opentofu() {
  echo 'output "hello" { value = "hi" }' >main.tf &&
    tofu init -input=false >/dev/null && tofu apply -input=false -auto-approve >/dev/null &&
    [ "$(tofu output -raw hello)" = hi ]
}

test_ansible() {
  ANSIBLE_HOME="$PWD" ansible localhost -i localhost, -c local -m ping | grep -q SUCCESS
}

test_ansible_lint() { # must find the task without a name
  printf -- '- hosts: all\n  tasks:\n    - ansible.builtin.command: echo hi\n' >playbook.yml
  ansible-lint --offline playbook.yml 2>&1 | grep -q 'name\[missing\]'
}

# --- Containers ------------------------------------------------------------

test_docker() {
  docker run --rm hello-world | grep -q 'Hello from Docker'
  local result=$?
  docker image rm hello-world >/dev/null 2>&1
  return $result
}

test_docker_compose() {
  printf 'services:\n  hello:\n    image: busybox\n    command: echo compose-works\n' >compose.yaml
  docker compose run --rm hello | grep -q compose-works
  local result=$?
  docker compose down >/dev/null 2>&1 # removes the network it made
  return $result
}

test_docker_buildx() {
  printf 'FROM busybox\nRUN echo built >/built.txt\n' >Dockerfile
  docker buildx build -q -t masbrew-smoke-test . >/dev/null &&
    [ "$(docker run --rm masbrew-smoke-test cat /built.txt)" = built ]
  local result=$?
  docker image rm masbrew-smoke-test >/dev/null 2>&1
  return $result
}

# --- Kubernetes (no cluster needed) ----------------------------------------

test_kubectl() {
  kubectl create deployment web --image=nginx --dry-run=client -o yaml | grep -q 'kind: Deployment'
}

test_helm() {
  helm create mychart >/dev/null && helm template mychart | grep -q 'kind: Deployment'
}

test_kustomize() {
  kubectl create deployment web --image=nginx --dry-run=client -o yaml >deployment.yaml &&
    printf 'resources:\n  - deployment.yaml\nnamePrefix: dev-\n' >kustomization.yaml &&
    kustomize build . | grep -q 'name: dev-web'
}

test_kubectx() { # lists the clusters in a test kubeconfig
  printf 'apiVersion: v1\nkind: Config\nclusters: []\nusers: []\ncontexts:\n- name: dev\n  context: {}\n- name: prod\n  context: {}\ncurrent-context: dev\n' >kubeconfig
  KUBECONFIG=kubeconfig kubectx | grep -q prod
}

# --- JSON, YAML & HTTP -----------------------------------------------------

test_jq() { echo '{"a": 1}' | jq -e '.a == 1' >/dev/null; }
test_yq() { [ "$(echo 'a: 1' | yq '.a')" = 1 ]; }

# httpie and wget download a file from a small local web server.
test_http_tools() {
  echo hello-http >page.txt
  local port=8765
  python3 -m http.server "$port" --bind 127.0.0.1 >/dev/null 2>&1 &
  local server=$! _
  for _ in 1 2 3 4 5 6 7 8 9 10; do # wait up to 10 seconds for the server
    curl -s "127.0.0.1:$port/page.txt" >/dev/null && break
    sleep 1
  done
  http --ignore-stdin --print=b GET "127.0.0.1:$port/page.txt" | grep -q hello-http &&
    wget -q -O - "http://127.0.0.1:$port/page.txt" | grep -q hello-http
  local result=$?
  kill "$server"
  return $result
}

# --- Languages & environment -----------------------------------------------

# shellcheck disable=SC2016 # the inner sh expands $GREETING
test_direnv() {
  mkdir project && echo 'export GREETING=hello-direnv' >project/.envrc &&
    XDG_DATA_HOME="$work" direnv allow project &&
    XDG_DATA_HOME="$work" direnv exec project sh -c 'echo $GREETING' | grep -q hello-direnv
}

# --- Shell & CLI utilities -------------------------------------------------

make_files() { mkdir -p files/sub && echo needle >files/sub/hay.txt; }

test_zoxide() {
  make_files && _ZO_DATA_DIR="$work" zoxide add "$PWD/files/sub" &&
    _ZO_DATA_DIR="$work" zoxide query sub | grep -q files/sub
}
test_fzf() { [ "$(printf 'apple\nbanana\n' | fzf --filter=ban)" = banana ]; }
test_ripgrep() { make_files && rg -q needle files; }
test_fd() { make_files && fd hay files | grep -q hay.txt; }
test_bat() { make_files && bat --paging=never --color=never files/sub/hay.txt | grep -q needle; }
test_eza() { make_files && eza --tree files | grep -q hay.txt; }
test_tree() { make_files && tree files | grep -q hay.txt; }
test_tldr() { tldr tar | grep -qi archive; } # downloads the pages the first time

test_rsync() {
  make_files && rsync -a files/ copy/ && [ -f copy/sub/hay.txt ] &&
    [ "$(command -v rsync)" = "$(brew --prefix)/bin/rsync" ]
}

# --- Every command is found in a new terminal ------------------------------

# All commands from the list: the bin/ folder of every CLI tool,
# plus the commands that some apps add (like copilot).
commands_from_list() {
  local name
  for name in $(brew bundle list --formula --file="$repo/Brewfile"); do
    ls "$(brew --prefix)/opt/$name/bin"
  done
  brew bundle list --cask --file="$repo/Brewfile" | xargs brew info --json=v2 --cask |
    jq -r '.casks[].artifacts[] | objects | select(has("binary")) | .target | split("/") | last'
}

# Open a new terminal (a clean zsh, like a new Terminal window) and look for each command.
test_commands_found() {
  local commands output missing
  commands="$(commands_from_list | sort -u | tr '\n' ' ')"
  # Your ~/.zshrc may print things too, so only read our own lines.
  # "all checked" at the end shows that the loop really ran.
  output="$(env -i HOME="$HOME" USER="$USER" LOGNAME="$LOGNAME" SHELL=/bin/zsh TERM=xterm-256color /bin/zsh -l -i -c \
    "for c in $commands; do whence -p \$c >/dev/null || echo \"command not found: \$c\"; done; echo all checked" \
    </dev/null 2>/dev/null)"
  missing="$(echo "$output" | grep '^command not found:')"
  echo "checked: $commands"
  echo "$output" | grep -q '^all checked$' || { echo "the new terminal did not finish"; return 1; }
  [ -z "$missing" ] || { echo "$missing"; return 1; }
}

# --- Apps (GUI and App Store) ----------------------------------------------

# Every app that Homebrew put in /Applications passes Gatekeeper and runs on Apple Silicon.
# (Apps that come as a .pkg, like Zoom, are checked by the macOS installer itself.)
test_app() {
  local app="/Applications/$1"
  [ -d "$app" ] || return 1
  spctl --assess --type execute "$app" || return 1
  local exe
  exe="$(defaults read "$app/Contents/Info" CFBundleExecutable)"
  lipo -archs "$app/Contents/MacOS/$exe" | grep -q arm64
}

# Every App Store app in Brewfile.apps is installed.
test_app_store_apps() {
  local id ids
  ids="$(grep '^mas ' "$repo/Brewfile.apps" | sed 's/.*id: *\([0-9]*\).*/\1/')"
  for id in $ids; do
    mas list | grep -q "^ *$id " || { echo "App Store id $id is not installed"; return 1; }
  done
}

# --- Run the checks --------------------------------------------------------

case "${1:-}" in
  "") unset HOMEBREW_MASBREW_CLI_ONLY ;;
  --cli-only) export HOMEBREW_MASBREW_CLI_ONLY=1 ;;
  *) echo "Unknown option: $1. The only option is --cli-only." >&2; exit 1 ;;
esac

echo "== Everything in the list is installed"
check "brew bundle check" brew bundle check --file="$repo/Brewfile"
check "every command is found in a new terminal" test_commands_found

echo "== CLI tools do their job"
check "git: make a commit" test_git
check "delta: show a diff" test_delta
check "pre-commit: read a config" test_pre_commit
check "shellcheck: find a bug" test_shellcheck
check "hadolint: find a Dockerfile mistake" test_hadolint
check "age: encrypt and decrypt" test_age
check "sops: encrypt and decrypt with age" test_sops
check "gitleaks: find a leaked token" test_gitleaks
check "trivy: find a leaked token" test_trivy
check "opentofu: apply a config" test_opentofu
check "ansible: ping this Mac" test_ansible
check "ansible-lint: find a playbook mistake" test_ansible_lint
check "kubectl: make a deployment" test_kubectl
check "helm: render a chart" test_helm
check "kustomize: build" test_kustomize
check "kubectx: list clusters" test_kubectx
check "jq: read JSON" test_jq
check "yq: read YAML" test_yq
check "httpie and wget: download a file" test_http_tools
check "direnv: load a folder's .envrc" test_direnv
check "zoxide: remember a folder" test_zoxide
check "fzf: filter a list" test_fzf
check "ripgrep: search text" test_ripgrep
check "fd: find a file" test_fd
check "bat: show a file" test_bat
check "eza: list files" test_eza
check "tree: show folders" test_tree
check "tldr: show a help page" test_tldr
check "rsync: copy a folder (newer rsync)" test_rsync
check "docker-credential-helper: runs" docker-credential-osxkeychain version
check "mise: runs" mise --version
check "stern: runs" stern --version
check "mole: runs" mo --version
check "gh: runs (sign in with: gh auth login)" gh --version
check "aws: runs (sign in with: aws configure)" aws --version
check "doctl: runs (sign in with: doctl auth init)" doctl version
check "supabase: runs (sign in with: supabase login)" supabase --version
check "copilot: runs (sign in on first start)" copilot --version
test_font() { brew list --cask font-jetbrains-mono-nerd-font | grep -q 'JetBrainsMonoNerdFont-Regular.ttf'; }
check "font: JetBrains Mono Nerd Font is installed" test_font

echo "== Docker"
if [ -n "${SKIP_DOCKER:-}" ]; then
  echo "skip  Docker checks (SKIP_DOCKER is set)"
else
  check "docker: run a container" test_docker
  check "docker compose: run a service" test_docker_compose
  check "docker buildx: build an image" test_docker_buildx
fi

if [ "${1:-}" != --cli-only ]; then
  echo "== Apps"
  # The .app names of the apps in Brewfile.apps that Homebrew moves to /Applications.
  apps="$(brew bundle list --cask --file="$repo/Brewfile.apps" | xargs brew info --json=v2 --cask |
    jq -r '.casks[].artifacts[] | objects | select(has("app")) | .app[] | strings')"
  while IFS= read -r app; do
    check "$app: signed and runs on Apple Silicon" test_app "$app"
  done <<<"$apps"
  check "App Store apps: all installed" test_app_store_apps
fi

echo
echo "$failed failed"
[ "$failed" -eq 0 ]
