$ErrorActionPreference = "Stop"
$key = "$HOME\.ssh\id_ed25519_homelab"
$ip  = tofu -chdir="$PSScriptRoot" output -raw control_node_ip

scp -i $key "$PSScriptRoot\bootstrap.sh" "root@${ip}:/root/bootstrap.sh"
if ($LASTEXITCODE) { exit $LASTEXITCODE }

ssh -i $key "root@$ip" "bash /root/bootstrap.sh"