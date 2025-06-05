#!/usr/bin/env bash
set -e
ACTION=${1:-"build"}  # Default to "build" if no argument is provided

# Clean up generated files
clean_up() {
    echo "Cleaning up previously generated files..."
    rm -rf bin obj *.wasm world.wit
    echo "Cleanup completed."
}

# Build the WebAssembly component using .NET SDK in a container
build_wasm() {
    echo "Building WebAssembly component..."

    echo "Step 1: Building .NET project in container..."
    podman run --rm \
        --mount type=bind,src=${PWD},dst=/app \
        --mount type=bind,src=${PWD}/../../world.wit,dst=/app/world.wit \
        mcr.microsoft.com/dotnet/sdk:10.0-preview \
        bash -c "cd /app && dotnet build"

    if [ $? -eq 0 ]; then
        echo "Build successful!"
        echo "To run it with the host application, use:"
        echo "  cd ../../host"
        echo "  cargo run -- --wasm-file ../components/xor_cs/bin/Debug/net10.0/xor_cs.wasm"
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
