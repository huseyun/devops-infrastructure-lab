# <------>
# Policies for secret configurations

path "infra/*" {
  capabilities = ["read", "create", "update", "delete", "list", "patch"]
}

path "app-dev/*" {
  capabilities = ["read", "create", "update", "delete", "list", "patch"]
}

path "app-prod/*" {
  capabilities = ["read", "create", "update", "delete", "list", "patch"]
}

# <------>
# Mount permissions

path "sys/mounts/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "sys/mounts" {
  capabilities = ["read"]
}

# <------>
# Policy permissions

path "sys/policies/acl" {
  capabilities = ["list"]
}

path "sys/policies/acl/*" {
  capabilities = ["read", "create", "update", "delete"]
}

# <------>
# Authentication permissions

path "sys/auth" {
  capabilities = ["read"]
}

path "sys/auth/*" {
  capabilities = ["read", "create", "update", "delete", "sudo"]
}

path "auth/userpass/*" {
  capabilities = ["read", "create", "update", "delete", "list"]
}

# Only token authentication is specifically controlled.

path "auth/token/create" {
  capabilities = ["create", "update", "sudo"]
}

path "auth/token/revoke" {
  capabilities = ["create", "update"]
}

path "sys/capabilities" {
  capabilities = ["create", "update"]
}
