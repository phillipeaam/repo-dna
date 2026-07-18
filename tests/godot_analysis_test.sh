#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$TEST_DIR/.." && pwd)"
TEMP="$(mktemp -d -p "$ROOT" .godot-analysis-test.XXXXXX)"
trap 'rm -rf "$TEMP"' EXIT

mkdir -p "$TEMP/scenes" "$TEMP/systems/combat" "$TEMP/systems/save" \
    "$TEMP/addons/quest_tools" "$TEMP/addons/gut" "$TEMP/tests" "$TEMP/localization"
cat > "$TEMP/project.godot" <<'EOF'
config_version=5
[application]
config/name="Quest Game"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.3", "GL Compatibility")
[autoload]
SaveManager="*res://systems/save/save_manager.gd"
[input]
attack={"deadzone": 0.5, "events": []}
[rendering]
renderer/rendering_method="gl_compatibility"
[internationalization]
locale/translations=PackedStringArray("res://localization/game.en.translation")
[editor_plugins]
enabled=PackedStringArray("res://addons/quest_tools/plugin.cfg")
EOF
cat > "$TEMP/scenes/main.tscn" <<'EOF'
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://systems/combat/combat_controller.gd" id="1"]
[node name="Main" type="Node2D"]
[node name="Combat" type="Node" parent="."]
script = ExtResource("1")
[node name="HUD" type="Control" parent="."]
[connection signal="attack" from="Combat" to="HUD" method="_on_attack"]
EOF
cat > "$TEMP/systems/combat/combat_controller.gd" <<'EOF'
extends Node
class_name CombatController
signal attacked
@export var damage := 10
func _physics_process(_delta):
    var target = find_child("Enemy")
    var config = load("res://systems/combat/combat_config.tres")
    get_node("../HUD").connect("ready", _on_ready)
func _on_ready():
    pass
EOF
printf 'extends Node\nfunc save_game():\n    pass\n' > "$TEMP/systems/save/save_manager.gd"
printf '[gd_resource type="Resource" format=3]\n' > "$TEMP/systems/combat/combat_config.tres"
cat > "$TEMP/addons/quest_tools/plugin.cfg" <<'EOF'
[plugin]
name="Quest Tools"
description="Quest editor"
author="Fixture"
version="1.0"
script="plugin.gd"
EOF
printf '@tool\nextends EditorPlugin\n' > "$TEMP/addons/quest_tools/plugin.gd"
printf 'extends GutTest\nfunc test_damage():\n    assert_eq(10, 10)\n' > "$TEMP/tests/test_combat.gd"
printf 'marker\n' > "$TEMP/addons/gut/.keep"
printf 'translation\n' > "$TEMP/localization/game.en.translation"
cat > "$TEMP/export_presets.cfg" <<'EOF'
[preset.0]
name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
EOF
printf '[configuration]\nentry_symbol = "godot_gdextension_init"\n' > "$TEMP/native.gdextension"

python - "$ROOT" "$TEMP" <<'PY'
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.argv[1]) / "collectors"))
from godot_analysis import analyze_godot
root = Path(sys.argv[2])
files = [{"path": p.relative_to(root).as_posix()} for p in root.rglob("*") if p.is_file()]
data = analyze_godot(root, files, {"_file_author_activity": {}})
assert data["status"] == "assessed"
assert data["project"]["godot_version"] == "4.3"
assert data["project"]["main_scene"] == "scenes/main.tscn"
assert data["summary"]["scenes"] == 1 and data["summary"]["scripts"] >= 4
assert data["autoloads"][0]["singleton"] is True
assert data["input_actions"] == ["attack"]
assert data["rendering"]["method"] == "gl_compatibility"
assert data["plugins"][0]["enabled"] is True
assert data["exports"][0]["platform"] == "Web"
assert "GUT" in data["tests"]["frameworks"]
assert data["native_extensions"] == ["native.gdextension"]
assert any(item["name"] == "Combat" for item in data["gameplay_systems"])
kinds = {item["type"] for item in data["signals"]}
assert {"tree_search", "dynamic_node_lookup", "runtime_load_in_frame_code", "manual_signal_connection"} <= kinds
report = {"generic_analysis": {"analysis": {"godot": data}}}
(root / "report.json").write_text(json.dumps(report), encoding="utf-8")
PY

python "$ROOT/renderers/godot_reports.py" "$TEMP/report.json" "$TEMP/out" \
    --schema "$ROOT/schemas/godot-analysis-1.0.0.schema.json"
[[ -f "$TEMP/out/index.html" && -f "$TEMP/out/analysis.json" && -f "$TEMP/out/gameplay_systems.txt" ]]
grep -q 'Combat' "$TEMP/out/gameplay_systems.txt"
echo 'godot analysis tests passed'
