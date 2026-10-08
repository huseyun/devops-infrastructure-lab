storage "raft" {
  path = "/opt/openbao/data"
  node_id = "openbao-1"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = true
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"