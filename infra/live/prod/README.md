# infra/live/prod

Same units as dev, against the prod account. `account.hcl` is what makes them
different, and the generator owns it.

State does not collide between the two: `root.hcl` keys it as
`<repo_name>/<path relative to the include>`, so dev and prod land at
`flake-hub-example-service/dev/ecr` and `flake-hub-example-service/prod/ecr` in
the same bucket.
