set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# 1) Tasiyici sistem araclari (surumu sonucu etkilemez -> apt)
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl git pipx extrepo

# 2) mise - resmi apt reposu (extrepo uzerinden)
if ! command -v mise >/dev/null 2>&1; then
  extrepo enable mise
  apt-get update
  apt-get install -y mise
fi

# 3) Shell aktivasyonu - satir zaten varsa ekleme
LINE='eval "$(mise activate bash)"'
grep -qxF "$LINE" "$HOME/.bashrc" 2>/dev/null || echo "$LINE" >> "$HOME/.bashrc"

# 4) Repoyu getir - zaten varsa dokunma
REPO_URL="${REPO_URL:-https://github.com/huseyun/devops-infrastructure-lab.git}"
REPO_DIR="/root/homelab"
[ -d "$REPO_DIR/.git" ] || git clone "$REPO_URL" "$REPO_DIR"

# 5) Pinli araclar - bu makine control node rolunde
export MISE_ENV=controlnode
LINE_ENV='export MISE_ENV=controlnode'
grep -qxF "$LINE_ENV" "$HOME/.bashrc" 2>/dev/null || echo "$LINE_ENV" >> "$HOME/.bashrc"

cd "$REPO_DIR"
mise trust
mise install

echo "git, pipx, mise hazir."