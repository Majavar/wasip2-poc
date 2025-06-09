#!/usr/bin/env bash
set -e
ACTION=${1:-"build"}  # Default to "build" if no argument is provided

# Clean up generated files
clean_up() {
    echo "Cleaning up previously generated files..."
    cargo clean
    echo "Cleanup completed."
}

# Build the WebAssembly component
build_wasm() {
    echo "Building WebAssembly component..."
    cargo build --release --target wasm32-wasip2

    if [ $? -eq 0 ]; then
        echo "Build successful! Component is available at target/wasm32-wasip2/release/add_rs.wasm"

    else
        echo "Build failed."
        exit 1
    fi
}

# Execute the requested action
case "$ACTION" in
    "clean")
        clean_up
        ;;
    "build")
        build_wasm
        ;;
    *)
        echo "Error: Invalid argument."
        echo "Usage: $0 [clean|build]"
        echo "  - 'clean': Remove previously generated files"
        echo "  - 'build': Build the WebAssembly component (default)"
        exit 1
        ;;
esac
