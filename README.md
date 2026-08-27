# April Fallen

Fallen Survival script for [Project Vector](https://project-vector-1.gitbook.io/vector-lua-engine/).

## Load in Vector

Paste this into a Vector script slot and execute:

```lua
utility.LoadUrl("https://raw.githubusercontent.com/Cunzaki/April/refs/heads/main/april.lua")
```

That always pulls the latest full `april.lua` runtime from GitHub `main` (one file — no split chunks).

Menu: **INSERT** (custom UI)

---

## Rebuild & ship

```bash
npm run build
git add april.lua load.lua "Script 1.lua" src scripts
git commit -m "Ship April vX.Y.Z"
git push origin main
```

After push, `utility.LoadUrl(...)` serves the new build.

---

## Repo layout

| Path | Purpose |
|------|---------|
| `src/` | Modular source — **edit here** |
| `docs/ARCHITECTURE.md` | How boot, frame loop, menu, and features fit together |
| `docs/API.md` | Vector Lua API |
| `april.lua` | Generated remote runtime |
| `Script 1.lua` | Identical local test copy of the runtime |
| `load.lua` | Same one-line LoadUrl shown above |
| `scripts/` | Bundle, dump, and asset tools |
| `src/ui/catalog_*.lua` | Per-tab custom-menu layouts |
| `src/ui/template/` | Standalone UI kit (no game features) |

**Local only (gitignored):** `dump/`, `RE/`, `node_modules/`

---

## License

Use at your own risk. Not affiliated with Project Vector or Fallen Survival.
