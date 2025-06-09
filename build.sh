#!/usr/bin/env bash
set -e

ACTION=${1:-"components"}  # Default to "components" if no argument is provided

# Print header for an action
print_header() {
    echo "========================================"
    echo "  $1"
    echo "========================================"
}

# Clean all components
clean_components() {
    print_header "Cleaning all components"

    # Clean add_rs (Rust component)
    echo -e "\n[1/4] Cleaning add_rs component..."
    pushd "${PWD}/components/add_rs"
    cargo clean
    popd
    echo "✓ add_rs cleaned"

    # Clean mul_c (C component)
    echo -e "\n[2/4] Cleaning mul_c component..."
    pushd "${PWD}/components/mul_c"
    ./build.sh clean
    popd
    echo "✓ mul_c cleaned"

    # Clean sub_py (Python component)
    echo -e "\n[3/4] Cleaning sub_py component..."
    pushd "${PWD}/components/sub_py"
    ./build.sh clean
    popd
    echo "✓ sub_py cleaned"

    # Clean xor_cs (C# component)
    echo -e "\n[4/4] Cleaning xor_cs component..."
    pushd "${PWD}/components/xor_cs"
    ./build.sh clean
    popd
    echo "✓ xor_cs cleaned"

    # Clean host/wasm folder
    echo -e "\nCleaning host/wasm folder..."
    if [ -d "${PWD}/host/wasm" ]; then
        rm -rf "${PWD}/host/wasm"
        echo "✓ host/wasm folder removed"
    else
        echo "✓ host/wasm folder doesn't exist"
    fi

    echo -e "\nAll components cleaned successfully!"
}

# Build all components
build_components() {
    print_header "Building all components"

    # Build add_rs (Rust component)
    echo -e "\n[1/4] Building add_rs component..."
    pushd "${PWD}/components/add_rs"
    ./build.sh build
    popd
    echo "✓ add_rs built"

    # Build mul_c (C component)
    echo -e "\n[2/4] Building mul_c component..."
    pushd "${PWD}/components/mul_c"
    ./build.sh build
    popd
    echo "✓ mul_c built"

    # Build sub_py (Python component)
    echo -e "\n[3/4] Building sub_py component..."
    pushd "${PWD}/components/sub_py"
    ./build.sh wasm
    popd
    echo "✓ sub_py built"

    # Build xor_cs (C# component)
    echo -e "\n[4/4] Building xor_cs component..."
    pushd "${PWD}/components/xor_cs"
    ./build.sh build
    popd
    echo "✓ xor_cs built"

    echo -e "\nAll components built successfully!"
}

# Copy all WASM files to host/wasm folder
copy_wasm_files() {
    print_header "Copying WASM files to host/wasm"

    # Create host/wasm folder if it doesn't exist
    mkdir -p "${PWD}/host/wasm"

    # Copy add_rs (Rust component)
    echo -e "\n[1/4] Copying add_rs component..."
    cp "${PWD}/components/add_rs/target/wasm32-wasip2/release/add_rs.wasm" "${PWD}/host/wasm/add.wasm" 2>/dev/null || echo "No add_rs.wasm file found to copy"

    # Copy mul_c (C component)
    echo -e "\n[2/4] Copying mul_c component..."
    cp "${PWD}/components/mul_c/mul.wasm" "${PWD}/host/wasm/" 2>/dev/null || echo "No mul.wasm file found to copy"

    # Copy sub_py (Python component)
    echo -e "\n[3/4] Copying sub_py component..."
    cp "${PWD}/components/sub_py/sub.wasm" "${PWD}/host/wasm/" 2>/dev/null || echo "No sub.wasm file found to copy"

    # Copy xor_cs (C# component)
    echo -e "\n[4/4] Copying xor_cs component..."
    cp "${PWD}/components/xor_cs/bin/Debug/net10.0/wasi-wasm/publish/xor_cs.wasm" "${PWD}/host/wasm/xor.wasm" 2>/dev/null || echo "No xor_cs.wasm file found to copy"

    echo -e "\nWASM files copied successfully to host/wasm folder!"
}

# Execute the requested action
case "$ACTION" in
    "clean")
        clean_components
        ;;
    "components")
        build_components
        copy_wasm_files
        ;;
    *)
        echo "Error: Invalid argument."
        echo "Usage: $0 [clean|components|copy-wasm]"
        echo "  - 'clean': Clean all components"
        echo "  - 'components': Build all components (default)"
        echo "  - 'copy-wasm': Copy WASM files to host/wasm folder"
        exit 1
        ;;
esac
