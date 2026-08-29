"""Run offline Lua tests with `python -m pip install lupa` (Lua 5.3 runtime)."""
from pathlib import Path
import os
import sys

from lupa.lua53 import LuaRuntime

root = Path(__file__).resolve().parents[1]
os.chdir(root)
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().SOURCE_ROOT = str(Path(sys.argv[1]).resolve()) if len(sys.argv) > 1 else str(root)
lua.execute((root / "tests/memory_regressions.lua").read_text(encoding="utf-8"))

# Compile, but never execute, source and generated runtimes against Lua 5.3.
compile_lua = lua.eval("function(text, name) local fn, err = load(text, name); assert(fn, err) end")
paths = list((root / "src").rglob("*.lua"))
paths += [root / name for name in ("april.lua", "Script 1.lua") if (root / name).exists()]
for path in paths:
    compile_lua(path.read_text(encoding="utf-8-sig"), str(path.relative_to(root)))
print(f"Lua 5.3 syntax: {len(paths)} files passed")
