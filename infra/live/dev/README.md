# infra/live/dev

Terragrunt units for the dev environment. These are yours: the generator
creates this directory, `account.hcl`, the root config and the deploy workflow,
nothing else.

One unit lives here:

| Unit | Source | What it makes |
| --- | --- | --- |
| `ecr` | `infra/units/ecr` | The ECR repository the container image is pushed to |

Plan it with `just plan env=dev`, apply it with `just apply env=dev`.

`aws_ecr_repository` reads `var.environment`, which is not declared anywhere in
`infra/units/ecr`. `root.hcl` generates it into the working directory at run
time. That is also why `tofu validate` fails if you run it against the unit on
its own — run it through terragrunt instead.
