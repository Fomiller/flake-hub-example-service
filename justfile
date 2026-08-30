# ---------------------------------------------------------------------------
# GENERATED FILE — managed by flake-hub (golden-base).
# Do not edit manually: `nix run .#generate` overwrites it.
# To change it, edit repo.nix, or the template in the pack that owns it.
# ---------------------------------------------------------------------------

import? 'just/base.just'

project := "flake-hub-example-service"
infraDir := "infra/live/dev"

fetch:
    curl -sSfL https://raw.githubusercontent.com/Fomiller/justfiles/refs/heads/main/base.just > just/base.just

generate:
    nix run .#generate

build:
    go build -o bin/ ./src/...

test:
    go test ./src/... -race -cover

plan-all:
    doppler run --name-transformer tf-var -- \
    terragrunt stack run --tf-path terraform --working-dir {{infraDir}} plan

apply-all:
    doppler run --name-transformer tf-var -- \
    terragrunt --non-interactive stack run --tf-path terraform --working-dir {{infraDir}} apply

docs:
    mdbook serve docs --open

docs-build:
    mdbook build docs
