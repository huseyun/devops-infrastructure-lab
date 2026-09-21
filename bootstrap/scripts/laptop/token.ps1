# Token tetigi. Laptop'ta calisir: proxmox-token.sh'i Proxmox host'una gonderip kosturur.
# Token degeri laptop'a hic ugramaz; host'ta dogar, dogrudan control node'a akar.
param(
  [Parameter(Mandatory)][string]$PveHost
)
$ErrorActionPreference = "Stop"
$BootstrapDir = (Resolve-Path "$PSScriptRoot\..\..").Path
$ScriptsDir   = (Resolve-Path "$PSScriptRoot\..").Path

$vmid = tofu -chdir="$BootstrapDir" output -raw control_node_vmid
if ($LASTEXITCODE -or -not $vmid) { throw "control_node_vmid okunamadi (tofu output)." }

scp "$ScriptsDir\pve-host\proxmox-token.sh" "${PveHost}:/tmp/proxmox-token.sh"
if ($LASTEXITCODE) { exit $LASTEXITCODE }

ssh $PveHost "bash /tmp/proxmox-token.sh $vmid; rc=`$?; rm -f /tmp/proxmox-token.sh; exit `$rc"
if ($LASTEXITCODE) { exit $LASTEXITCODE }