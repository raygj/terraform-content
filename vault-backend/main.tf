# vault backend TF code for Sentinel training
# sentinel policy requires certain auth backends and path with prefix jray
resource "vault_auth_backend" "jray_example" {
  type = "github"
  path = "jray-github"
}