# INITIALIZING OPENBAO

## Purpose

Having an initialized OpenBao instance with 3 key pieces that is unsealable with 2 of them.

## Scope

### Used for

Newly created vault.

### NOT used for

Reinstall or transfering a vault.

## Prerequisities

- Has an installed, uninitialized OpenBao instance with the [guide](./install-openbao.md)

## Steps

### 1. Initialization

- initialize the vault:

```bash
bao operator init \
-key-shares=3 \
-key-threshold=2
```

### 2. Save the keys

- Save the 3 keys into three separate environments.

### 3. Unseal the safe

- [Unseal](./unseal-openbao.md) the safe with two at-hand, seal it by supplying initial root token with no visibility and sealing:

```bash
read -rs BAO_TOKEN && export BAO_TOKEN   # enter token after this command
bao operator seal
unset BAO_TOKEN  
```

Then, unseal again with one at-hand and one far-away key.

## Verification

- `bao status` should return `Initialized true`, `Sealed false`, 

```bash
Initialized             true
Sealed                  false
Total Shares            3
Threshold               2
```