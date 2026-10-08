# INSTALLING OPENBAO

## Purpose

In the control node, having an OpenBao instance that is:
- Configured with Shamir secret sharing.

## Scope

### Used for

Bootstrapping a brand new OpenBao instance on the control node, providing all applications running on the infrastructure secrets.

### NOT used for

.

## Prerequisites

- Access to a node with at least 2GBs of RAM.

## Steps
**Runs on: node as root(pct enter)**

### 1. Installation

- Install the package:

```bash
cd /tmp
curl -fsLO https://github.com/openbao/openbao/releases/download/v2.7.1/openbao_2.7.1_linux_amd64.deb
apt install ./<openbao-deb-file>
```

#### Check

After the installation, the expected output should be:

```bash
...
Generating OpenBao TLS key and self-signed certificate...
```

### 2. Service configuration

- Stop the service:

```bash
systemctl stop openbao
```

- Check the configuration by:

```bash
systemctl cat openbao
```

Verify these outputs:
```conf
MemorySwapMax=0
User=openbao
Group=openbao
ExecStart=/usr/bin/bao server -config=/etc/openbao/openbao.hcl
```

If values are expected, skip the next step. if not, research the new changes and change the workflow accordingly if necessary.

### 3. Data folder configuration

- OpenBao uses vault folder `/opt/openbao/data` by default. to ensure only user `openbao` is able to change what's inside:

```bash
install -d -o openbao -g openbao -m 700 /opt/openbao/data
```

### 4. Config file deployment

- copy the necessary configuration file from the ops users' downloaded repository into the configuration destination:

```bash
cd /home/ops/<git-repo-name>
cp -f openbao.hcl /etc/openbao/
```

- Change the ownership and permissions:

```bash
chown root:openbao /etc/openbao/openbao.hcl
chmod 640 /etc/openbao/openbao.hcl
```

#### Check

Verify the ownership and permissions of file:

```bash
ls -l /etc/openbao/openbao.hcl
```
*Expected output: `-rw-r----- 1 root openbao 216 ...`*

### 5. Starting OpenBao

- Start it now, and make it start at every restart:

```bash
systemctl enable --now openbao
```