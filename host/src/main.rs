use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use tracing::{Level, debug, info};
use tracing_subscriber::{EnvFilter, fmt, prelude::*};
use wasmtime::{
    Config, Engine, Store,
    component::{Component, Linker, ResourceTable},
};
use wasmtime_wasi::p2::{IoView, WasiCtx, WasiCtxBuilder, WasiView};

// Define the application state
pub struct State {
    table: ResourceTable,
    wasi: WasiCtx,
}

// Import bindings for the world in the wit file
wasmtime::component::bindgen!({
    path: "../world.wit",
    async: true,
});

impl IoView for State {
    fn table(&mut self) -> &mut ResourceTable {
        &mut self.table
    }
}

impl WasiView for State {
    fn ctx(&mut self) -> &mut WasiCtx {
        &mut self.wasi
    }
}

// Implement the host interface for the example world
impl nve::wasm_component::host::Host for State {
    async fn log(&mut self, message: String) {
        info!("{}", message);
    }
}

#[derive(Parser)]
struct Cli {
    /// Path to the WebAssembly component file
    #[arg(short, long)]
    wasm_file: PathBuf,

    /// First operand for the process function
    #[arg()]
    a: i32,

    /// Second operand for the process function
    #[arg()]
    b: i32,

    /// Verbosity level (-v = info, -vv = debug, -vvv = trace)
    #[arg(short, action = clap::ArgAction::Count, default_value_t = 2)]
    verbose: u8,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    let level = match cli.verbose {
        0 => Level::ERROR,
        1 => Level::WARN,
        2 => Level::INFO,
        3 => Level::DEBUG,
        _ => Level::TRACE,
    };

    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env().add_directive(level.into()))
        .init();

    info!(
        "Starting WebAssembly host application with verbosity level: {}",
        level
    );

    // Configure the engine
    let mut config = Config::new();
    config.async_support(true);

    let engine = Engine::new(&config)?;
    let mut linker = Linker::new(&engine);
    wasmtime_wasi::p2::add_to_linker_async(&mut linker)?;

    debug!("Initializing WASI context");
    let table = ResourceTable::new();
    let wasi_ctx = WasiCtxBuilder::new().build();
    let state = State {
        table,
        wasi: wasi_ctx,
    };
    let mut store = Store::new(&engine, state);

    debug!("Loading WebAssembly component from: {:?}", cli.wasm_file);
    let component = Component::from_file(&engine, &cli.wasm_file)?;
    WasmComponent::add_to_linker(&mut linker, |state| state)?;
    let instance = WasmComponent::instantiate_async(&mut store, &component, &linker).await?;

    // Call the exported functions from the WASM component
    info!("Calling component functions");

    // Get the component name
    let name = instance
        .call_name(&mut store)
        .await?;
    info!(component_name = %name, "Retrieved component name");

    // Call the process function with two integers
    let result = instance
        .call_process(&mut store, cli.a, cli.b)
        .await?;
    info!(a = cli.a, b = cli.b, result = result, "Executed process function");

    info!("WebAssembly host application completed successfully");
    Ok(())
}
