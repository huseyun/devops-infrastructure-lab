# UNSEAL THE SAFE

## Runner

ops, without root.

## Steps

### 1. Verify the safe is sealed

- Verify it is sealed by:

```bash
bao status
```

### 2. Unseal

- For two times, write and supply the unseal keys:

```bash
bao operator unseal
```

#### Check

```bash
bao status
```
*Expected output: Sealed    false*