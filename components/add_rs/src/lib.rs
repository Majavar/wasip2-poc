wit_bindgen::generate!({ path: "../.." });

struct Adder;

impl exports::nve::wasm_component::guest::Guest for Adder {
    fn name() -> String {
        "add".to_string()
    }

    fn process(a: i32, b: i32) -> i32 {
        nve::wasm_component::host::log(&format!("Adding {a} + {b}"));
        a + b
    }
}

export!(Adder);
