include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/units/ecr"
}

inputs = {
  repository_name = "flake-hub-example-service"
}
