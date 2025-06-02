# WebAssembly Component Host

This Rust project serves as a host application for running WebAssembly components that implement the interface defined in `../world.wit`.

## Requirements

- Rust (edition 2024 or newer)
- wasmtime-cli (optional, for running components directly)

## Building

Build the host application with:
```
cargo build --release
```

## Usage

Run a WebAssembly component with:
```
cargo run --release -- --wasm-file ../components/add_rs/target/wasm32-wasip2/release/add_rs.wasm
```

Or use the built executable directly:
```
./target/release/host --wasm-file ../components/add_rs/target/wasm32-wasip2/release/add_rs.wasm
```

## Features

- Implements the host interface defined in the WIT file
- Provides a log function that components can use
- Calls the component's exported functions
