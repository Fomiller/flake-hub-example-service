# flake-hub-example-service

A Go service with every [flake-hub](https://github.com/Fomiller/flake-hub) pack
turned on: `golden-base`, `golden-github`, `golden-service`, `golden-infra`,
`golden-argocd` and `golden-docs`. This is the fully built-out example. For the
smallest possible one, see
[flake-hub-example](https://github.com/Fomiller/flake-hub-example).

Everything comes out of one file. `repo.nix` is 36 lines, and it produces 35.

## What is generated and what is not

Generated files carry a header naming the pack that owns them.

| Path | Owner | Class |
| --- | --- | --- |
| `.gitignore`, `justfile` | golden-base | managed |
| `README.md`, `AGENTS.md` | golden-base, golden-github | scaffold |
| `.github/CODEOWNERS`, `renovate.json`, `.github/workflows/generate.yml`, `.github/workflows/ci.yml`, `.github/workflows/publish-image.yml`, `.github/workflows/publish-chart.yml` | golden-github | managed |
| `Dockerfile` | golden-service | managed |
| `infra/live/root.hcl`, `infra/live/service.hcl`, `infra/live/tags.hcl`, `infra/live/version.hcl`, `infra/live/*/account.hcl`, `.github/workflows/deploy-infra.yml` | golden-infra | managed |
| `infra/live/*/README.md`, `infra/live/*/terragrunt.stack.hcl` | golden-infra | scaffold |
| `argocd.yaml` | golden-argocd | managed |
| `helm/<chart>/Chart.yaml`, `helm/<chart>/values.yaml`, `helm/<chart>/templates/*`, `argocd/overlays/values.app.base.yaml`, `argocd/overlays/*/kustomization.yaml`, `argocd/overlays/*/values.app.yaml`, `argocd/overlays/*/values.kargo.yaml` | golden-argocd | scaffold |
| `docs/book.toml`, `docs/theme/catppuccin.css`, `.github/workflows/docs.yml` | golden-docs | managed |
| `docs/src/SUMMARY.md`, `docs/src/introduction.md` | golden-docs | scaffold |

Managed files are rewritten on every run. Scaffold files are written once and
then left alone — this README is one of them.

Everything else is hand-written and stays that way:

- `src/` — the service itself
- `infra/units/**` and `infra/stacks/**` — the terragrunt units and the wiring
  between them. The packs build the frame, never the units.

There is no Argo CD `Application` manifest in this repo. The homelab cluster has
one ApplicationSet that reads `argocd.yaml` from each repo it lists and builds
the Application from it, pointed at `argocd/overlays/<env>` here. `argocd.yaml`
is the only managed file golden-argocd writes — everything it deploys is
scaffold, because what a service deploys changes for reasons `repo.nix` never
sees.

## How one key reaches five files

`language = "go"` picks the build and test commands in the `justfile`, the CI
steps in `ci.yml`, the base images in the `Dockerfile`, and `bin/` in
`.gitignore`. Nothing else in `repo.nix` mentions Go.

`service.port = 8080` reaches the `Dockerfile` and the chart's Service and
Deployment. `argocd.replicas = 2` reaches both values files.

## How a deploy is put together

Two ECR repositories, both at the registry root:

- `flake-hub-example-service` — the image, pushed by `publish-image.yml`
- `flake-hub-example-service-chart` — the chart, pushed by `publish-chart.yml`

The chart is at `helm/flake-hub-example-service/`, but `Chart.yaml` names it
`flake-hub-example-service-chart`. `helm push` reads the repository name out of
the packaged chart, so the suffix has to be part of the chart's own name. The
`-chart` suffix is trimmed back off inside the templates, so no rendered
resource carries it.

`publish-chart.yml` names no chart. The workflow walks `helm/*/Chart.yaml`, so
a second chart here would be published with no workflow change.

Both repositories are created by `infra/units/aws/common/ecr`.

`argocd/overlays/<env>/kustomization.yaml` pulls that chart back down and
inflates it with two values files: the shared
`argocd/overlays/values.app.base.yaml` first, then the environment's own
`values.app.yaml`. Later wins on any key both set.

The same kustomization installs `kargo-project-chart` beside the workload, so a
service is one Application rather than two. Kargo rewrites the chart versions in
that file on every promotion, which is why the overlay is scaffold — a
regenerate would put the bootstrap versions back and roll the environment
backwards. `argocd.kargo = false` leaves it out.

`argocd.environment` picks the one environment this repo deploys to, and only
that overlay is seeded. It is `"dev"` here; setting it to `"prod"` seeds the prod
overlay instead. The base asks for 2 replicas and dev overrides it down to 1,
which is what the two-file split is for. Render it by hand to see:

```sh
helm template dev helm/flake-hub-example-service \
  -f argocd/overlays/values.app.base.yaml \
  -f argocd/overlays/dev/values.app.yaml
```

## The infra layout

```
infra/
  live/
    root.hcl  service.hcl  tags.hcl  version.hcl
    <env>/
      account.hcl
      terragrunt.stack.hcl
      README.md
  stacks/aws/common/terragrunt.stack.hcl
  units/aws/common/ecr/
```

Only those three files per environment are committed. `terragrunt stack run`
writes the unit directories into `infra/live/<env>/`, and they are gitignored.

`aws/common` means once per account, not once per environment. Only `dev`
exists here, so it declares the stack. A second environment on the same account
would declare nothing.

## Working on it

```sh
just build      # go build -o bin/ ./src/...
just test       # go test ./src/... -race -cover
just plan-all   # terragrunt stack run plan against infra/live/dev
just docs       # serve the book at localhost:3000
just generate   # rewrite the generated files after editing repo.nix
```

## Turning a pack off

`infra.enabled`, `argocd.enabled` and `docs.enabled` each delete their whole
directory when set to false — hand-written files included, not just the
generated ones. That is deliberate: `infra/units/**` with no `infra/live/` frame
is dead code. Nothing here sets them, so all three trees stay.

## The book

`golden-docs` seeds an mdbook site under `docs/`. `book.toml`, the Catppuccin
stylesheet and the workflow are managed; the pages themselves are scaffold, so
they are written once and then this repo's to edit. `docs.yml` publishes to
Pages on push to main.

## A note on CI

`deploy-infra.yml`, `publish-chart.yml` and `publish-image.yml` are disabled in
this repo. They are real and correctly wired, and they now resolve a real role
through OIDC. What is missing is everything they would act on: the ECR
repositories and the terragrunt state, neither of which has been applied. So
leaving them on would just paint the repo red. `CI` and `Generate` run for real.

Docs: https://fomiller.github.io/flake-hub/
