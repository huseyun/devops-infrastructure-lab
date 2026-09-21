$ErrorActionPreference = "Stop"
$BootstrapDir = (Resolve-Path "$PSScriptRoot\..\..").Path
$ScriptsDir   = (Resolve-Path "$PSScriptRoot\..").Path
$key = "$HOME\.ssh\id_ed25519_homelab"

$ip = tofu -chdir="$BootstrapDir" output -raw control_node_ip
if ($LASTEXITCODE -or -not $ip) { throw "Control node IP okunamadi (tofu output)." }

scp -i $key "$ScriptsDir\control-node\bootstrap.sh" "root@${ip}:/root/bootstrap.sh"
if ($LASTEXITCODE) { exit $LASTEXITCODE }

ssh -i $key "root@$ip" "bash /root/bootstrap.sh"
if ($LASTEXITCODE) { exit $LASTEXITCODE }