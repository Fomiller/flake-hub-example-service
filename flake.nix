{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    golden-engine.url = "github:Fomiller/flake-hub?dir=golden-engine&ref=refs/tags/golden-engine-0.3.0";
    golden-base.url = "github:Fomiller/flake-hub?dir=golden-base&ref=refs/tags/golden-base-0.2.1";
    golden-base.inputs.nixpkgs.follows = "nixpkgs";
    golden-base.inputs.golden-engine.follows = "golden-engine";
    golden-github.url = "github:Fomiller/flake-hub?dir=golden-github&ref=refs/tags/golden-github-0.3.0";
    golden-github.inputs.nixpkgs.follows = "nixpkgs";
    golden-github.inputs.golden-engine.follows = "golden-engine";
    golden-service.url = "github:Fomiller/flake-hub?dir=golden-service&ref=refs/tags/golden-service-0.3.0";
    golden-service.inputs.nixpkgs.follows = "nixpkgs";
    golden-service.inputs.golden-engine.follows = "golden-engine";
    golden-infra.url = "github:Fomiller/flake-hub?dir=golden-infra&ref=refs/tags/golden-infra-0.1.0";
    golden-infra.inputs.nixpkgs.follows = "nixpkgs";
    golden-infra.inputs.golden-engine.follows = "golden-engine";
    golden-argocd.url = "github:Fomiller/flake-hub?dir=golden-argocd&ref=refs/tags/golden-argocd-0.2.1";
    golden-argocd.inputs.nixpkgs.follows = "nixpkgs";
    golden-argocd.inputs.golden-engine.follows = "golden-engine";
  };

  outputs = { self, nixpkgs, flake-utils, golden-engine, golden-base, golden-github, golden-service, golden-infra, golden-argocd }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        golden = golden-engine.lib.mkGolden {
          packs = [ golden-base.pack golden-github.pack golden-service.pack golden-infra.pack golden-argocd.pack ];
        } pkgs (import ./repo.nix);
      in
      {
        apps.generate = golden.generateApp;
        packages.golden-files = golden.filesDrv;
      });
}
