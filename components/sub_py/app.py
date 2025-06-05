import wit_world
from wit_world import imports
from wit_world.imports import host

class WitWorld(wit_world.WitWorld):
    def name(self) -> str:
        return "sub"

    def process(self, a: int, b: int) -> int:
        host.log(f"Sub called with a={a}, b={b}")
        return a - b