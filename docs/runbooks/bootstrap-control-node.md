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
pveversion -v
```

Should return the version of the running Proxmox VE.

- Having a Debian Template in the file storage.

Check if a Debian container image is present:

```bash
pveam list <local-directory-storage-name>
```

Should return a Debian LXC container template.

## Steps

.

## Verification

- From the laptop, `ssh <operator>@<control-node>` logs in with the operator key, without a password prompt.

## Reverting

.

## Meta

Haven't run yet. First version.

This runbook is supposed to only work for Proxmox VE servers.