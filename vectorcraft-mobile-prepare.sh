#!/usr/bin/env bash
# Mobile-first VectorCraft UI patch.
# The build workflow copies this to adapters/vectorcraft/prepare.sh before running build.sh.
set -Eeuo pipefail
APP="${1:-vectorcraft}"
SRC="${3:-}"

if [[ "$APP" != "vectorcraft" || -z "$SRC" ]]; then
  echo "VectorCraft mobile patch skipped for app=$APP"
  exit 0
fi

python3 - "$SRC" <<'PY'
from pathlib import Path
import sys

src = Path(sys.argv[1])
p = src / "crates/ui-egui/src/dock.rs"
s = p.read_text()

needle = 'pub fn show(app: &mut VectorcraftApp, ui: &mut Ui) {\n    if crate::panel_docking::show(app, ui) {'
replacement = '''pub fn show(app: &mut VectorcraftApp, ui: &mut Ui) {
    // On phone-sized windows, start with the large Properties/Layers dock collapsed so
    // the canvas remains usable. Re-apply only when entering mobile width; the user can
    // still expand the dock manually while staying in that orientation.
    let mobile_width = ui.ctx().content_rect().width() < 720.0;
    let mobile_width_key = egui::Id::new("vectorcraft-mobile-width-state");
    let was_mobile = ui.ctx().data(|d| d.get_temp::<bool>(mobile_width_key)).unwrap_or(false);
    if mobile_width && !was_mobile {
        app.ui.dock_collapsed = true;
    }
    ui.ctx().data_mut(|d| d.insert_temp(mobile_width_key, mobile_width));
    if crate::panel_docking::show(app, ui) {'''
if "vectorcraft-mobile-width-state" in s:
    print("Mobile dock patch already present; no changes needed.")
elif s.count(needle) != 1:
    raise SystemExit(f"Could not safely patch {p}: expected one dock show() marker, found {s.count(needle)}")
else:
    p.write_text(s.replace(needle, replacement, 1))
    print("Applied mobile dock auto-collapse patch to", p)
PY
