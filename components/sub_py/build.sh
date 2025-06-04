#!/usr/bin/env bash
set -e
ACTION=${1:-"wasm"}  # Default to "wasm" if no argument is provided

# Clean up generated files based on the action
clean_up() {
    echo "Cleaning up previously generated files..."
    rm -rf wit_world
}

# Generate Python bindings from WIT
generate_bindings() {
    echo "Generating Python bindings from WIT..."
    componentize-py --wit-path ../../world.wit --world wasm-component bindings .
}

# Build the WebAssembly component
build_wasm() {
    echo "Building WebAssembly component..."
    componentize-py --wit-path ../../world.wit --world wasm-component componentize app -o sub.wasm
}

# Execute the requested action
case "$ACTION" in
    "bindings")
        clean_up
        generate_bindings
        echo "Python bindings generated successfully."
        ;;
    "wasm")
        clean_up
        generate_bindings
        build_wasm
        ;;
    "clean")
        clean_up
        echo "Cleanup completed."
        ;;
    *)
        echo "Error: Invalid argument."
        echo "Usage: $0 [bindings|wasm|clean]"
        echo "Available actions:"
        echo "  - 'clean': Remove previously generated files"
        echo "  - 'bindings': Generate only Python bindings from WIT"
        echo "  - 'wasm': Generate bindings and build the WebAssembly component"
        exit 1
        ;;
esac
