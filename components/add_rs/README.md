# add_rs WebAssembly Component

This project implements a WebAssembly component that provides addition functionality
based on the WIT interface defined in `../../world.wit`.

## Requirements

- Rust with edition 2024 support (nightly toolchain recommended)
- wasm32-wasip2 target: `rustup target add --toolchain nightly wasm32-wasip2`
- wasm-tools: `cargo install wasm-tools`
- Rust standard library for WebAssembly: `rustup component add --toolchain nightly rust-src`
- wasmtime (optional, for running the component)

## Building

To build the WebAssembly component:

1. Make sure you have all the requirements installed
2. The project is configured to target wasm32-wasip2 in `.cargo/config.toml`
3. Simply build the project:
   ```
   cargo build --release
   ```

This will produce a WebAssembly component file in `target/wasm32-wasip2/release/add_rs.wasm` that implements the WIT interface.

## Interface

The component implements:

- `name()`: Returns the string "add"
- `process(a: s32, b: s32) -> s32`: Returns the sum of `a` and `b`

It also imports and uses:
- `log(message: string)`: Logs messages to the host environment

## Running the Component

You can run this component using a WebAssembly runtime that supports components, such as:

- wasmtime
- wasm-runtime-rs
- wasmCloud
