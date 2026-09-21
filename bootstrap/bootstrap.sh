set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl git pipx extrepo

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
[ -f "$HOME/.ssh/id_ed25519" ] || \
  ssh-keygen -q -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" -C "control-plane@node-control"

if ! command -v mise >/dev/null 2>&1; then
  extrepo enable mise
  apt-get update
  apt-get install -y mise
fi

LINE='eval "$(mise activate bash)"'
grep -qxF "$LINE" "$HOME/.bashrc" 2>/dev/null || echo "$LINE" >> "$HOME/.bashrc"

REPO_URL="${REPO_URL:-https://github.com/huseyun/devops-infrastructure-lab.git}"
REPO_DIR="/root/homelab"
[ -d "$REPO_DIR/.git" ] || git clone -b full-restructure "$REPO_URL" "$REPO_DIR"

export MISE_ENV=controlnode
LINE_ENV='export MISE_ENV=controlnode'
grep -qxF "$LINE_ENV" "$HOME/.bashrc" 2>/dev/null || echo "$LINE_ENV" >> "$HOME/.bashrc"

cd "$REPO_DIR"
mise trust
mise install

# test
mise exec -- tofu version
mise exec -- ansible --version
ssh-keygen -lf "$HOME/.ssh/id_ed25519.pub"

echo "git, pipx, mise hazir."