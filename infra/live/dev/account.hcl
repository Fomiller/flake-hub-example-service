# ---------------------------------------------------------------------------
# GENERATED FILE — managed by flake-hub (golden-infra).
# Do not edit manually: `nix run .#generate` overwrites it.
# To change it, edit repo.nix, or the template in the pack that owns it.
# ---------------------------------------------------------------------------

locals {
  environment = "dev"
  region      = "us-east-1"
  profile     = "fomiller-dev"
  # Overrides the name root.hcl would derive. variables.hcl still wins.
  state_bucket = "fomiller-tfstate-all"
}
