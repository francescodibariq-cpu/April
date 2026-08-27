import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const catalogDir = path.join(ROOT, "src/ui");
const catalog = fs.readdirSync(catalogDir)
  .filter((name) => name.startsWith("catalog") && name.endsWith(".lua"))
  .sort()
  .map((name) => fs.readFileSync(path.join(catalogDir, name), "utf8"))
  .join("\n");
const combat = fs.readFileSync(path.join(ROOT, "src/ui/combat_labels.lua"), "utf8");
const tooltips = fs.readFileSync(path.join(ROOT, "src/ui/tooltips.lua"), "utf8");
const esp = fs.readFileSync(path.join(ROOT, "src/game/esp_maps.lua"), "utf8");
const gpu = fs.readFileSync(path.join(ROOT, "src/core/gpu_chams.lua"), "utf8");
const hud = fs.readFileSync(path.join(ROOT, "src/ui/hud_dock.lua"), "utf8");

const set = new Set();
function add(s) {
  if (!s || typeof s !== "string") return;
  if (s.startsWith("april_")) return;
  if (s.length < 2 || s.length > 200) return;
  set.add(s);
}

// Quoted strings that look like labels (contain a letter and usually space or capitals)
for (const src of [catalog, combat, esp, gpu, hud]) {
  for (const m of src.matchAll(/"([^"\\]{2,120})"/g)) {
    const t = m[1];
    if (/^[a-z][a-z0-9_]*$/.test(t)) continue; // identifiers
    if (t.includes("%d") || t.includes("%.") ) {
      // keep format-ish UI labels like "%d"
    }
    if (/[A-Za-z]/.test(t)) add(t);
  }
}

// tip BY_ID values
const tips = {};
for (const m of tooltips.matchAll(/^\s*(april_[a-z0-9_]+)\s*=\s*"([^"]*)"/gm)) {
  tips[m[1]] = m[2];
  add(m[2]);
}

// OPTION tip arrays - skip for now if complex

const labels = [...set].filter((s) => s.length <= 80 && !s.includes(". ")).sort();
const tipList = Object.keys(tips).sort().map((k) => `${k}\t${tips[k]}`);

fs.writeFileSync(path.join(ROOT, "tools/ui_labels.txt"), labels.join("\n"), "utf8");
fs.writeFileSync(path.join(ROOT, "tools/ui_tips.tsv"), tipList.join("\n"), "utf8");
console.log("labels", labels.length, "tips", tipList.length);
