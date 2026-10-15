# CONFIGURE OPENBAO

## Purpose

Having a OpenBao instance with:

- Appropriate mount points.
- Applied written policies.

## Scope

### Used for

- A newly initialized OpenBao instance.

- Committed configuration for an already initialized instance.

### NOT used for

Initializing, unsealing or reinstalling from a backup.

## Prerequisites

- Having a token with operator policy. Initial root token for first time entry.

- Being inside the repository folder.

## Steps

### 1. Logging in with an operator token

- Enter the operator key without making it visible in the console by running `bao login`.

#### Check

Verify token authorization level:

```bash
bao token lookup
```
*expected output: `policies     [operator/root]`*

Token helper file is saved to `~/.vault-token`.

### 2. Create required mounts

#### Check

Verify which mounts you need to install by:

```bash
bao secrets list
```

Every mount that is not listed here should be initialized by:

- Create the uninitialized mounts by:

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

### 4. Open userpass and create admin user

- Create the admin user, and pass the password invisibly by:

```bash
bao auth enable userpass
bao auth list

read -rs PW
echo -n "$PW" | bao write auth/userpass/users/<user-name> \
  password=- \
  token_policies=admin \
  token_ttl=3h \
  token_max_ttl=15h
unset PW
```

#### Check

Verify added user and their available admin policy:

```bash
bao read auth/userpass/users/<user-name>
```
*Expected output: token_policies=[admin] and correct TTL times.*

## Verification

- Check whether the mounts were succesfully added by listing mounts:

```bash
bao secrets list -detailed
```
*Expected output: all added mounts listed.*

- Check whether all policies were added by:

```bash
bao policy list
```
*Expected output: all policy files were added named by their file name.*

- Check whether all policies match the file they were added from by:

```bash
for f in openbao/policies/*.hcl; do
  diff <(bao policy read "$(basename "$f" .hcl)") "$f" && echo "OK $f"
done
```
*Expected output: all policy files are OK'd.*

## Reverting

## Meta
