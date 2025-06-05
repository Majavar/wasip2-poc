#!/usr/bin/env bash
set -e
ACTION=${1:-"build"}  # Default to "build" if no argument is provided

# Clean up generated files
clean_up() {
    echo "Cleaning up previously generated files..."
    rm -f wasm_component.c wasm_component.h wasm_component_component_type.o mul.p1.wasm mul.wasm
}

# Generate C bindings from WIT
generate_bindings() {
    echo "Generating C bindings from WIT..."
    wit-bindgen c ../../world.wit
}

# Build the WebAssembly component
build_wasm() {
    echo "Building WebAssembly component..."

    echo "Step 1: Compiling C code in container..."
    podman run --rm --mount type=bind,src=${PWD},dst=/app ghcr.io/webassembly/wasi-sdk:wasi-sdk-25 \
        sh -c "cd /app && \${CC} wasm_component.c mul.c wasm_component_component_type.o -o mul.p1.wasm -mexec-model=reactor"

    echo "Step 2: Converting to WebAssembly component..."
    wasm-tools component new ./mul.p1.wasm -o mul.wasm

    if [ $? -eq 0 ]; then
        echo "Build successful! Component is available at mul.wasm"
        echo "To run it with the host application, use:"
        echo "  cd ../../host"
        echo "  cargo run -- --wasm-file ../components/mul_c/mul.wasm"
    else
        echo "Build failed."
        exit 1
    fi
}

# Execute the requested action
case "$ACTION" in
    "clean")
        clean_up
        echo "Cleanup completed."
        ;;
    "bindings")
        clean_up
        generate_bindings
        echo "C bindings generated successfully."
        ;;
    "build")
        # For build, we need to ensure bindings exist
        if [ ! -f "wasm_component.h" ]; then
            echo "Bindings not found. Generating them first..."
            generate_bindings
        fi
        build_wasm
        ;;
    *)
        echo "Error: Invalid argument."
        echo "Usage: $0 [clean|bindings|build]"
        echo "  - 'clean': Remove previously generated files"
        echo "  - 'bindings': Generate only C bindings from WIT"
        echo "  - 'build': Build the WebAssembly component (default)"
        exit 1
        ;;
esac
