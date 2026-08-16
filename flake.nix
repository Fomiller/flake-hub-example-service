{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    golden-engine.url = "github:Fomiller/flake-hub?dir=golden-engine&ref=refs/tags/golden-engine-0.2.0";
    golden-base.url = "github:Fomiller/flake-hub?dir=golden-base&ref=refs/tags/golden-base-0.1.0";
    golden-base.inputs.nixpkgs.follows = "nixpkgs";
    golden-base.inputs.golden-engine.follows = "golden-engine";
    golden-github.url = "github:Fomiller/flake-hub?dir=golden-github&ref=refs/tags/golden-github-0.3.0";
    golden-github.inputs.nixpkgs.follows = "nixpkgs";
    golden-github.inputs.golden-engine.follows = "golden-engine";
    golden-service.url = "github:Fomiller/flake-hub?dir=golden-service&ref=refs/tags/golden-service-0.2.0";
    golden-service.inputs.nixpkgs.follows = "nixpkgs";
    golden-service.inputs.golden-engine.follows = "golden-engine";
  };

  outputs = { self, nixpkgs, flake-utils, golden-engine, golden-base, golden-github, golden-service }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        golden = golden-engine.lib.mkGolden {
          packs = [ golden-base.pack golden-github.pack golden-service.pack ];
        } pkgs (import ./repo.nix);
      in
      {
        apps.generate = golden.generateApp;
        packages.golden-files = golden.filesDrv;
      });
}
