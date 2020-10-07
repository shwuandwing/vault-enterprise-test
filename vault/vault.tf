terraform {
}

provider "vault" {
  address = "http://127.0.0.1:8200"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"

  tune {
    max_lease_ttl      = "90000s"
    listing_visibility = "unauth"
    token_type         = "default-batch"
  }
}

resource "vault_generic_endpoint" "user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/user"
  ignore_absent_fields = true
  data_json = <<EOT
{
  "policies" : ["user"],
  "password" : "password",
  "token_type" : "batch"
}
EOT
}

resource "vault_policy" "user" {
  name = "user"

  policy = <<EOT
path "*" {
  capabilities = ["create","update","read","list","delete","sudo"]
}
EOT
}


resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "For encryption/decryption"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "test" {
  backend = vault_mount.transit.path
  name    = "test"
  type    = "aes256-gcm96"
}

