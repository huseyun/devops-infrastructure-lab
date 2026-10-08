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

- Get the wanted OpenBao version download link from GitHub page.

- Install the package:

```bash
cd /tmp
curl -fsLO https://github.com/openbao/openbao/releases/download/v2.7.1/openbao_2.7.1_linux_amd64.deb
dpkg -i <openbao-deb-file>
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

- Read the following values:

```conf
MemorySwapMax=0
User=openbao
Group=openbao
ExecStart=/usr/bin/bao server -config=/etc/openbao/openbao.hcl
```

If values are expected, skip the next step. if not:

- Change the values by entering service edit mode by:

```bash
systemctl edit openbao
```

Change the required lines, and remove the hashtag from the beginning of every change.

### 3. Data folder configuration

- OpenBao uses vault folder `/opt/openbao/data` by default. to ensure only user `openbao` is able to change what's inside:

```bash
install -d -o openbao -g openbao -m 700 /opt/openbao/data
```

### 4. Config file deployment

.

### 5. Starting OpenBao

- Start it now, and make it start at every restart:

```bash
systemctl enable --now openbao
```


## temporary

$vmid=<control-node-ip>