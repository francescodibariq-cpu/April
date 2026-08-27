import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const files = [
  "src/ui/catalog.lua",
  "src/ui/catalog_items.lua",
  "src/ui/catalog_aim.lua",
  "src/ui/catalog_visuals.lua",
  "src/ui/catalog_world.lua",
  "src/ui/catalog_guns.lua",
  "src/ui/catalog_misc.lua",
  "src/ui/catalog_radar.lua",
  "src/ui/catalog_config.lua",
  "src/ui/combat_labels.lua",
  "src/ui/hud_dock.lua",
  "src/ui/gs_widgets.lua",
  "src/ui/custom_menu.lua",
  "src/ui/startup_intro.lua",
  "src/core/feature_bind.lua",
  "src/features/utility/keybind_viewer.lua",
  "src/features/utility/event_status.lua",
  "src/features/utility/mod_checker.lua",
  "src/features/visuals/target_overlay.lua",
  "src/features/combat/bullet_hud.lua",
  "src/game/esp_maps.lua",
  "src/core/gpu_chams.lua",
  "src/ui/tooltips.lua",
];

const set = new Set();
for (const rel of files) {
  const s = fs.readFileSync(path.join(ROOT, rel), "utf8");
  for (const m of s.matchAll(/"([^"\\]{2,120})"/g)) {
    const t = m[1];
    if (/^[a-z0-9_./\\%-]+$/i.test(t) && !/[ A-Z]/.test(t.slice(1))) continue;
    if (t.startsWith("april_")) continue;
    if (t.includes("%") && !/[A-Za-z]{3}/.test(t)) continue;
    if (/^[\d.\s]+$/.test(t)) continue;
    if (t.includes("\\")) continue;
    // keep strings that look user-facing (have letters + space or Title Case word)
    if (!/[A-Za-z]/.test(t)) continue;
    set.add(t);
  }
}
const out = [...set].sort();
fs.writeFileSync(path.join(ROOT, "tools/ui_strings.txt"), out.join("\n"));
console.log("wrote", out.length, "strings");
