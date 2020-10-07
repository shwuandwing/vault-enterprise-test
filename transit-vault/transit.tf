terraform {
}

provider "vault" {
  address = "http://127.0.0.1:8202"
  token   = "root"
}

resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "For auto-unseal"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "key" {
  backend = vault_mount.transit.path
  name    = "auto-unseal"
  type    = "aes256-gcm96"
}