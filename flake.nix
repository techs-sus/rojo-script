{
  description = "a development shell which provides an environment containing rust, bun, and rojo";

  # binary cache for wally-nix (needs to be in the root flake too)
  nixConfig = {
    extra-substituters = "https://techs-sus-wally-nix.cachix.org";
    extra-trusted-public-keys = "techs-sus-wally-nix.cachix.org-1:hOye+Fj1heELMgDJOzDoQnFLsQA/kVN0ZVRnZmsAyB4=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    wally-nix = {
      url = "github:techs-sus/wally-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      wally-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        wally = wally-nix.packages.${system}.default;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.rust-bin.stable.latest.default.override {
              extensions = [
                "rust-analyzer"
                "rust-src"
              ];
            })
          ];

          packages = [
            pkgs.bun
            pkgs.rojo

            # TODO: how would run-in-roblox work?
            wally
          ];

          shellHook = "";
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
