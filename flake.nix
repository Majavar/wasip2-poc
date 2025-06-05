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
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          pip
          virtualenv
          setuptools
          wheel
        ]);
      in
      with pkgs;
      {
        devShells.default = mkShell.override { stdenv = stdenvNoCC; } {
          buildInputs = [
            pythonEnv
            rust
            vscode
            wit-bindgen
            wasm-tools
          ];

          # Shell hook to set up the Python environment
          shellHook = ''
            # Create a Python virtual environment if it doesn't exist
            VENV_DIR="$PWD/.venv"
            if [ ! -d "$VENV_DIR" ]; then
              echo "Creating Python virtual environment in $VENV_DIR"
              ${pythonEnv}/bin/python -m venv "$VENV_DIR"
            fi

            # Activate the virtual environment
            source "$VENV_DIR/bin/activate"

            # Install required packages if not already installed
            if ! pip show componentize-py > /dev/null 2>&1; then
              echo "Installing componentize-py package..."
              pip install componentize-py
            fi

            echo "Python virtual environment is ready."
            echo "You can build the Python WebAssembly component with:"
            echo "cd components/sub_py && ./build.sh"
          '';
        };
      }
    );
}
