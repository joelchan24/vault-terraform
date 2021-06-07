resource "vault_auth_backend" "userpass"{
    type= "userpass"
}

resource "vault_auth_backend" "approle"{
    type= "approle"
}

resource "vault_auth_backend" "github"{
    type= "github"
}

# Policies document
data "vault_policy_document" "admin_policy_doc" {
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }
}

data "vault_policy_document" "key_officer_doc" {
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "delete", "list"]
    description  = "allow all on secrets"
  }
}


data "vault_policy_document" "audit_doc" {
  rule {
    path         = "secret/*"
    capabilities = [ "read",  "list"]
    description  = "allow read and list"
  }
}

# Policies

resource "vault_policy" "admin_policy" {
  name   = "admin_policy"
  policy = "${data.vault_policy_document.admin_policy_doc.hcl}"
}

resource "vault_policy" "key_officer" {
  name   = "key_officer"
  policy = "${data.vault_policy_document.key_officer_doc.hcl}"
}

resource "vault_policy" "audit" {
  name   = "key_officer"
  policy = "${data.vault_policy_document.audit_doc.hcl}"
}


#Users 

/* resource "vault_github_auth_backend" "joeltest24" {
  organization = "joeltest24"
} */


resource "vault_generic_endpoint" "joelgit" {
  depends_on           = [vault_auth_backend.github]
  path                 = "auth/github/config"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "organization": "joeltest24"
}
EOT
}

resource "vault_github_user" "tf_user" {
  backend  = vault_auth_backend.github.id
  user     = "joelchan24"
  policies = ["admin_policy", "key_officer"]
} 

# Add Users


resource "vault_generic_endpoint" "joel" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/joel"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admin_policy", "key_officer"],
  "password": "joel24"
}
EOT
}

resource "vault_generic_endpoint" "joelo2" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/joel2"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admin_policy", "key_officer"],
  "password": "joel24"
}
EOT
}