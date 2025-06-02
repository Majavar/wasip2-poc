{
  description = "Play with WASI p2";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config = {allowUnfree = true;};
        };
        rust = pkgs.rust-bin.stable."1.87.0".minimal.override {
          extensions = [ "rustfmt" "clippy" "rust-src" "rust-analyzer" ];
          targets = [ "wasm32-wasip2" "x86_64-unknown-linux-gnu" ];
        };
      in 
      with pkgs;
      {
        devShells.default = mkShell.override { stdenv = stdenvNoCC; } {
          buildInputs = [
            python3
            rust
            vscode
          ];
        };
      }
    );
}
