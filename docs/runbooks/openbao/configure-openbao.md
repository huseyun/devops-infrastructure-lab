# CONFIGURE OPENBAO

## Purpose

Having a newly initialized OpenBao instance with:

- appropriate operator roles.
- Applied written policies.

## Scope

### Used for

- A newly initialized OpenBao instance.

- Committed configuration for an already initialized instance.

### NOT used for

.

## Prerequisities

- Having a token with operator policy. Initial root token for first time entry.

- Being inside the repository folder.

## Steps

### 1. Logging in with an operator key

- Enter the operator key without making it visible in the console by running `bao login`.

#### Check

.

### 2. Create required mounts

- Create the required mounts by:

```bash
bao secrets enable -path=infra -version=2 kv
bao secrets enable -path=app-prod -version=2 kv
bao secrets enable -path=app-dev -version=2 kv
```

### 3. Upload policies

- Upload the required policies by:

```bash
for f in openbao/policies/*.hcl; do
  bao policy write "$(basename "$f" .hcl)" "$f"
done
```

## Verification

## Reverting

## Meta