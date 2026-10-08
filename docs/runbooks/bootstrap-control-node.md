# BOOTSTRAPPING THE CONTROL NODE

## Purpose

Obtaining a LXC that is:
- Able to run Ansible, OpenTofu Terraform for future infrastructure configurations to run on.
- Configured to retrieve secrets from Infisical cloud service.

## Scope

### Used for

Bootstrapping a new control node or replacing an already installed control node for an infrastructure.

### NOT used for

- Creating a new guest.
- Rotating the Proxmox API token → see `rotate-proxmox-token.md`.
- Tool version upgrades.

## Prerequisites 

- A working Proxmox Hypervisor Server with the ability to SSH as root into it.

Check whether the server is running by SSH'ing into it:

```bash
ssh root@<ip-address-of-proxmox>
```

After entering the root password, entering:

```bash
pveversion
```

Should return the version of the running Proxmox VE.

- Knowing the DHCP pool of the router and selecting a static IP outside it.

- SSH public and private key pair in the operating device.

Entering:

```bash
ls ~/.ssh
```

shoud yield pair of SSH key files.

## Steps

### 1. Connecting and defining variables required

**Run on: Proxmox host**

- Get the next available VM ID by running:

```bash
pvesh get /cluster/nextid
```

- Get the directory storage and lvmthin storage names by running:

```bash
pvesm status
```

- Update the available container templates, and get the list of all available templates:

```bash
pveam update
pveam available --section system
```

- Acquire bridge name

```bash
ip link show type bridge
```

- Define the variables for the shell session for one time use:

```bash
vmid=<next-available-vm-id>
ct_hostname=<hostname>
ct_ip=<static-ip>/<prefix>
ct_gateway=<gateway-to-router>
bridge=<bridge-name>
template_storage=<local-storage-name>
rootfs_storage=<rootfs-storage-name>
template=<template-name>
```

### 2. CT template download if not existent
**Run on: Proxmox host**

- Check if a Debian container image is present:
```bash
pveam list "$template_storage"
```

- If template is not present, download it by running:
```bash
pveam download "$template_storage" "$template"
```

### 3. Transfer operator public SSH key to Proxmox host


- In operator machine, transfer the public SSH key by:
**Run on: Operator machine**

```bash
scp "$env:USERPROFILE/.ssh/id_ed25519_homelab.pub" root@<proxmox-host-ip>:/root/operator.pub
```

### 4. Create the control node LXC
**Run on: Proxmox host**

- Create the LXC by:

```bash
pct create $vmid "$template_storage:vztmpl/$template" \
--hostname "$ct_hostname" \
--unprivileged 1 \
--features nesting=1 \
--net0 name=eth0,bridge="$bridge",gw="$ct_gateway",ip="$ct_ip" \
--cores 1 \
--memory 1536 \
--rootfs "$rootfs_storage":8 \
--onboot 1 \
--ssh-public-keys /root/operator.pub
```

### 5. Update and install base packages
**Run on: Proxmox host**

- Update and install base packages:

```bash
pct exec "$vmid" -- apt-get update
pct exec "$vmid" -- apt-get upgrade -y

pct exec "$vmid" -- apt-get install -y curl git extrepo

pct exec "$vmid" -- extrepo enable mise
pct exec "$vmid" -- apt-get update
pct exec "$vmid" -- apt-get install -y mise
```

### 6. Create non-sudoer user and copy the SSH key to it

#### Create the operations user and give it the SSH key
**Run on: Proxmox host**

```bash
pct exec "$vmid" -- useradd -m -s /bin/bash ops

pct exec "$vmid" -- mkdir -p /home/ops/.ssh
pct exec "$vmid" -- cp /root/.ssh/authorized_keys /home/ops/.ssh/
pct exec "$vmid" -- chown -R ops:ops /home/ops/.ssh
pct exec "$vmid" -- chmod 700 /home/ops/.ssh
pct exec "$vmid" -- chmod 600 /home/ops/.ssh/authorized_keys
```

##### Check
**Run on: operator machine**

Verify that SSH configuration is valid by trying to connect to the machine:

```bash
ssh ops@<control-node-ip>
```

### 7. Disable root SSH into control node

**Run on: Proxmox host**

- Turn off root SSH:

```bash
pct exec "$vmid" -- sh -c 'echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/10-disable-root.conf'
```

- Verify the configuration is valid and activate it in the active session:

```bash
pct exec "$vmid" -- sshd -t
pct exec "$vmid" -- systemctl reload ssh
```

### 8. Configure mise activation and environment information
**Run on: control node as ops**

- Activate mise and configure the environment in all bash sessions:

```bash
echo 'export MISE_ENV=controlnode' >> ~/.bashrc
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

### 9. Main repository configuration
**Run on: control node as ops**

- Clone the repo via HTTPS and trust mise inside the repository:

```bash
git clone <https-clone-link>
cd <repo-dir>
mise trust
mise install
```

#### Check

Check if activation and installation is correct:

```bash
tofu --version
ansible --version
```
*Expected output: Ansible and OpenTofu returning versions without errors.*

## Verification

- From the operating device, `ssh <operator>@<control-node-ip>` logs in with the operator key, without a password prompt.

## Reverting

- Stop the machine and destroy it by:

```bash
pct stop <vmid>
pct destroy <vmid>
```

## Meta

Haven't run yet. First version.

This runbook is supposed to only work for Proxmox VE servers.