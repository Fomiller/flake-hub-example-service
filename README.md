# flake-hub-example-service

A Go service with every [flake-hub](https://github.com/Fomiller/flake-hub) pack
turned on: `golden-base`, `golden-github`, `golden-service`, `golden-infra` and
`golden-argocd`. This is the fully built-out example. For the smallest possible
one, see
[flake-hub-example](https://github.com/Fomiller/flake-hub-example).

Everything comes out of one file. `repo.nix` is 28 lines, and it produces 22.

## What is generated and what is not

Generated files carry a header naming the pack that owns them.

| Path | Owner | Class |
| --- | --- | --- |
| `.gitignore`, `.editorconfig`, `.envrc`, `justfile` | golden-base | managed |
| `README.md` | golden-base | scaffold |
| `CODEOWNERS`, `renovate.json`, `.github/workflows/generate.yml`, `.github/workflows/ci.yml` | golden-github | managed |
| `Dockerfile` | golden-service | managed |
| `infra/live/root.hcl`, `infra/live/service.hcl`, `infra/live/*/account.hcl`, `.github/workflows/deploy-infra.yml` | golden-infra | managed |
| `infra/live/*/README.md` | golden-infra | scaffold |
| `helm/<chart>/Chart.yaml`, `helm/<chart>/templates/*`, `argocd/overlays/*/kustomization.yaml`, `.github/workflows/publish-chart.yml` | golden-argocd | managed |
| `helm/<chart>/values.yaml`, `argocd/overlays/values.app.base.yaml`, `argocd/overlays/*/values.app.yaml` | golden-argocd | scaffold |

Managed files are rewritten on every run. Scaffold files are written once and
then left alone — this README is one of them.

Everything else is hand-written and stays that way:

- `src/` — the service itself
- `infra/units/**` and `infra/live/*/ecr/` — the terragrunt units. The packs
  build the frame, never the units.
- `argocd/applications/*.yaml` — the Argo CD Applications, one per environment,
  each pointing at that environment's overlay in this repo

## How one key reaches five files

`language = "go"` picks the build and test commands in the `justfile`, the CI
steps in `ci.yml`, the base images in the `Dockerfile`, and `bin/` in
`.gitignore`. Nothing else in `repo.nix` mentions Go.

`service.port = 8080` reaches the `Dockerfile` and the chart's Service and
Deployment. `deploy.replicas = 2` reaches both values files.

## How a deploy is put together

The chart is at `helm/flake-hub-example-service/`, named after the repo.
`publish-chart.yml` pushes it to ECR as an OCI artifact.

`argocd/overlays/<env>/kustomization.yaml` pulls that chart back down and
inflates it with two values files: the shared
`argocd/overlays/values.app.base.yaml` first, then the environment's own
`values.app.yaml`. Later wins on any key both set.

That split does real work here. The base asks for 2 replicas; dev overrides it
to 1 and prod does not, so prod keeps 2. dev runs `:latest`, prod runs
`:v0.1.0`. Render either by hand to see it:

```sh
helm template dev helm/flake-hub-example-service \
  -f argocd/overlays/values.app.base.yaml \
  -f argocd/overlays/dev/values.app.yaml
```

`argocd/applications/` is hand-written. Each Application points Argo CD at one
overlay path in this repo.

## Working on it

```sh
just build      # go build -o bin/ ./src/...
just test       # go test ./src/... -race -cover
just plan       # terragrunt plan, dev by default
just generate   # rewrite the generated files after editing repo.nix
```

## A note on CI

`deploy-infra.yml` and `publish-chart.yml` are disabled in this repo. They are
real and correctly wired, but they assume an AWS account that does not exist,
so leaving them on would just paint the repo red. `CI` and `Generate` run for
real.

Docs: https://fomiller.github.io/flake-hub/
