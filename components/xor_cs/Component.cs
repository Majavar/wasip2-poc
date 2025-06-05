using WasmComponentWorld.wit.imports.nve.wasmComponent;

namespace WasmComponentWorld;

public class WasmComponentWorldImpl : IWasmComponentWorld
{
    public static string Name()
    {
        return "xor";
    }

    public static int Process(int x, int y)
    {
        HostInterop.Log($"XORing {x} and {y}");
        return x ^ y;
    }
}
