provider "singlestoredb" {
  api_key = var.singlestore_api_key
}

resource "singlestoredb_workspace_group" "example" {
  name            = "example-workspace-group"
  region_id       = var.singlestore_region_uuid
  firewall_ranges = var.single_store_ips
}

resource "singlestoredb_workspace" "example" {
  name               = "example-workspace"
  workspace_group_id = singlestoredb_workspace_group.example.id
  size               = "S-0"
}

output "workspace_endpoints" {
  value = singlestoredb_workspace.example.endpoint
}