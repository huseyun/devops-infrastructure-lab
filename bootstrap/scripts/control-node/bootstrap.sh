#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl git extrepo openssh-client

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
[ -f "$HOME/.ssh/id_ed25519" ] || \
  ssh-keygen -q -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" -C "control-plane@node-control"

if ! command -v mise >/dev/null 2>&1; then
  extrepo enable mise
  apt-get update
  apt-get install -y mise
fi

LINE_ACT='eval "$(mise activate bash)"'
grep -qxF "$LINE_ACT" "$HOME/.bashrc" 2>/dev/null || echo "$LINE_ACT" >> "$HOME/.bashrc"

REPO_URL="${REPO_URL:-https://github.com/KULLANICI/devops-infrastructure-lab.git}"
REPO_DIR="/root/homelab"
[ -d "$REPO_DIR/.git" ] || git clone -b full-restructure "$REPO_URL" "$REPO_DIR"

export MISE_ENV=controlnode
LINE_ENV='export MISE_ENV=controlnode'
grep -qxF "$LINE_ENV" "$HOME/.bashrc" 2>/dev/null || echo "$LINE_ENV" >> "$HOME/.bashrc"

cd "$REPO_DIR"
mise trust
mise install

mise exec -- tofu version
mise exec -- ansible --version
ssh-keygen -lf "$HOME/.ssh/id_ed25519.pub"

echo "Katman2 tamam: git, mise, tofu, ansible, kontrol duzlemi SSH kimligi hazir."