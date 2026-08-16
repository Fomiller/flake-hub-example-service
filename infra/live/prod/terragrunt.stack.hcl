# Written once, then it is yours. `nix run .#generate` never touches it again.
#
# Which stacks this environment gets. Each source is a directory under
# infra/stacks/, which names the units under infra/units/.
#
# `terragrunt stack run` generates the unit directories into this one. They are
# gitignored, so nothing under infra/live/prod/ except this file, account.hcl
# and the README belongs in git.
#
# Empty on purpose. The only stack this repo has is aws/common, and "common"
# means once per account. Both environments here share one account, so dev
# applies it and prod does not. A prod stack belongs here the moment this repo
# grows a unit that really is per-environment.

locals {
  stacks_path  = find_in_parent_folders("stacks")
  account_vars = read_terragrunt_config("${get_terragrunt_dir()}/account.hcl")
}
