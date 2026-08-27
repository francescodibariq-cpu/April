# Offline Lua regression checks

From the project root, with Python and the `lupa` package installed:

```powershell
python -m pip install lupa
python tests/run_lua.py
```

The runner uses Lua 5.3, mocks Vector APIs without network calls or game writes,
and compiles every source file plus the generated `april.lua` and `Script 1.lua`.
Run `npm run build` before testing the generated runtime.

Coverage includes bounded moving-target searches, unchanged result TTLs and ray
budgets, resumed search progress, image ownership/eviction, lazy announcer loads,
map failure/asset-change cleanup, map disk access, existing GC retry intervals,
the documented `applygc(payload)` signature, and frame cleanup during the intro.
Card-door tests also exercise the real keypicker registration, toggle/hold binds,
notifications, GC failures, config snapshot fields, and three-second maintenance
without creating a thread or replacing the frame hook.

These checks do not measure Vector's native RAM/GPU allocations. Before release,
load the rebuilt `Script 1.lua` in a fresh Vector session and verify combat,
announcer first-load behavior, map pan/zoom, and RAM over an extended session.
The existing `actor_fullbright.lua` is a separate manual game test.
