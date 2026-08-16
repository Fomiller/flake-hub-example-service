# flake-hub-example-service

A Go service managed by [flake-hub](https://github.com/Fomiller/flake-hub):
`golden-base`, `golden-github` and `golden-service`.

`golden-service` marks `language` required, so `repo.nix` sets `language =
"go"`. That one key picks the build and test commands in the `justfile`, the
CI steps, and the Dockerfile base image.

The Go code is real but trivial — an HTTP handler and its test — so CI and
`docker build` have something to chew on.

To change something, edit `repo.nix` and run:

```sh
nix run .#generate
```

Docs: https://fomiller.github.io/flake-hub/
