{
  description = "a development shell which provides an environment containing rust, bun, and rojo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = with pkgs; mkShell {
          buildInputs = [
            (rust-bin.stable.latest.default.override {
              extensions = [ "rust-analyzer" "rust-src" ];
            })
          ];

          packages = [
            bun
            rojo

            # TODO: how would run-in-roblox work? wally is pending a custom nix package
          ];


          shellHook = "";
        };
      }
    );
}
