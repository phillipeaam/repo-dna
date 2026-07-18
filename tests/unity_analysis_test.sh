#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/Assets/_Project/Combat" "$TMP/Assets/AddressableAssetsData/AssetGroups" "$TMP/Assets/Plugins/Android" "$TMP/ProjectSettings" "$TMP/Packages"
printf '%s' '{"dependencies":{"com.unity.render-pipelines.universal":"17.0.3","com.unity.inputsystem":"1.11.2","com.unity.addressables":"2.3.16","com.unity.localization":"1.5.4"}}' > "$TMP/Packages/manifest.json"
printf '%s\n' 'm_EditorVersion: 6000.0.1f1' > "$TMP/ProjectSettings/ProjectVersion.txt"
printf '%s\n' 'PlayerSettings:' '  activeInputHandler: 1' '  scriptingBackend: {Standalone: 1}' '  apiCompatibilityLevel: 6' '  scriptingDefineSymbols: TESTING;LIVEOPS' '  Android: enabled' > "$TMP/ProjectSettings/ProjectSettings.asset"
printf '%s\n' '  - enabled: 1' '    path: Assets/Scenes/Main.unity' '  - enabled: 0' '    path: Assets/Scenes/Debug.unity' > "$TMP/ProjectSettings/EditorBuildSettings.asset"
printf '%s\n' '  name: Low' '  name: High' > "$TMP/ProjectSettings/QualitySettings.asset"
printf '%s\n' '  m_CustomRenderPipeline: {fileID: 11400000, guid: abc}' > "$TMP/ProjectSettings/GraphicsSettings.asset"
printf '%s\n' '  m_Name: Default Local Group' > "$TMP/Assets/AddressableAssetsData/AssetGroups/Default.asset"
printf '%s' '{"name":"Game.Tests","optionalUnityReferences":["TestAssemblies"]}' > "$TMP/Assets/_Project/Game.Tests.asmdef"
printf '%s' 'native' > "$TMP/Assets/Plugins/Android/game.aar"
for name in CombatController Weapon Damage Health Projectile; do
  printf '%s\n' 'using UnityEngine;' "public class $name : MonoBehaviour {" ' void Update() {' '  foreach (var enemy in enemies) { Instantiate(prefab); }' '  var target = GameObject.Find("Target");' '  var component = GetComponent<Rigidbody>();' '  var values = enemies.Where(x => x.active).ToList();' ' }' ' void OnEnable() { button.onClick.AddListener(Attack); StartCoroutine(Run()); }' '}' > "$TMP/Assets/_Project/Combat/$name.cs"
done
PYTHONPATH="$ROOT/collectors" python - "$TMP" <<'PY'
import sys
from pathlib import Path
from unity_analysis import analyze_unity
root=Path(sys.argv[1]); files=[]
for path in root.rglob('*'):
    if path.is_file():
        rel=path.relative_to(root).as_posix(); files.append({"path":rel,"language":"C#" if rel.endswith('.cs') else None,"lines":len(path.read_text(errors='ignore').splitlines())})
code={"symbols":[{"path":item["path"],"name":Path(item["path"]).stem} for item in files if item["path"].endswith('.cs')],"imports":[]}
activity={item["path"]:{"Alice":{"commits":10,"churn":200}} for item in files if item["path"].endswith('.cs')}
git={"_file_author_activity":activity,"most_changed_files":[{"path":path,"commits":10} for path in activity]}
result=analyze_unity(root,files,code,git,{"module_graph":{"cycles":[["Combat","Core"]]}}); config=result["configuration"]
assert config["build"]["enabled_scenes"] == ["Assets/Scenes/Main.unity"]
assert config["rendering"]["pipeline"] == "URP" and config["input"]["system"] == "New Input System"
assert config["localization_package_version"] == "1.5.4"
assert config["assemblies"]["test_assemblies"] == ["Assets/_Project/Game.Tests.asmdef"]
assert config["addressables"]["groups"][0]["name"] == "Default Local Group"
assert config["native_plugins"][0]["platform"] == "Android"
combat=next(item for item in result["gameplay_systems"] if item["name"] == "Combat")
assert combat["confidence"] == "high" and combat["file_count"] == 5 and combat["git"]["matching_commit_touches"] == 50
types={item["type"] for item in result["signals"]}
assert {"frequent_object_lookup","instantiate_destroy_in_loop","linq_in_frame_method","get_component_in_frame_method","coroutine_lifecycle","event_listener_lifecycle","approximate_dependency_cycle"} <= types
assert all(item["severity"] == "review" for item in result["signals"])
PY
echo "Unity analysis tests passed"
