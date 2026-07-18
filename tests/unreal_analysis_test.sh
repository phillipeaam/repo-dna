#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; ROOT="$(cd "$TEST_DIR/.." && pwd)"
TEMP="$(mktemp -d -p "$ROOT" .unreal-analysis-test.XXXXXX)"; trap 'rm -rf "$TEMP"' EXIT
mkdir -p "$TEMP/Source/QuestGame/Combat" "$TEMP/Source/QuestGame/Tests" "$TEMP/Plugins/QuestTools/Source/QuestTools" "$TEMP/Config" "$TEMP/Content/Combat" "$TEMP/Content/Maps"
cat > "$TEMP/QuestGame.uproject" <<'EOF'
{"FileVersion":3,"EngineAssociation":"5.4","TargetPlatforms":["Win64"],"Modules":[{"Name":"QuestGame","Type":"Runtime","LoadingPhase":"Default"}],"Plugins":[{"Name":"GameplayAbilities","Enabled":true}]}
EOF
cat > "$TEMP/Source/QuestGame/QuestGame.Build.cs" <<'EOF'
using UnrealBuildTool;
public class QuestGame : ModuleRules { public QuestGame(ReadOnlyTargetRules Target) : base(Target) { PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs; PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "GameplayAbilities" }); PrivateDependencyModuleNames.Add("UMG"); } }
EOF
cat > "$TEMP/Source/QuestGame.Target.cs" <<'EOF'
using UnrealBuildTool;
public class QuestGameTarget : TargetRules { public QuestGameTarget(TargetInfo Target) : base(Target) { Type = TargetType.Game; ExtraModuleNames.Add("QuestGame"); } }
EOF
cat > "$TEMP/Source/QuestGame/Combat/CombatCharacter.h" <<'EOF'
#pragma once
UCLASS(Blueprintable)
class QUESTGAME_API ACombatCharacter : public ACharacter {
 GENERATED_BODY()
 UPROPERTY(EditAnywhere, Replicated) float Health;
 UFUNCTION(Server, Reliable) void ServerAttack();
 virtual void Tick(float DeltaSeconds) override;
};
EOF
cat > "$TEMP/Source/QuestGame/Combat/CombatCharacter.cpp" <<'EOF'
#include "CombatCharacter.h"
void ACombatCharacter::Tick(float DeltaSeconds) { Super::Tick(DeltaSeconds); UGameplayStatics::GetAllActorsOfClass(GetWorld(), AActor::StaticClass(), Actors); LoadObject<UObject>(nullptr, TEXT("/Game/Combat/Data")); }
EOF
cat > "$TEMP/Source/QuestGame/Tests/CombatSpec.cpp" <<'EOF'
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FCombatTest, "Quest.Combat", EAutomationTestFlags::EditorContext)
bool FCombatTest::RunTest(const FString&) { return true; }
EOF
cat > "$TEMP/Plugins/QuestTools/QuestTools.uplugin" <<'EOF'
{"FileVersion":3,"VersionName":"1.0","FriendlyName":"Quest Tools","EnabledByDefault":true,"Modules":[{"Name":"QuestTools","Type":"Editor"}]}
EOF
cat > "$TEMP/Config/DefaultInput.ini" <<'EOF'
[/Script/Engine.InputSettings]
+ActionMappings=(ActionName="Attack",Key=LeftMouseButton)
EOF
printf 'binary fixture\n' > "$TEMP/Content/Combat/BP_CombatCharacter.uasset"
printf 'binary fixture\n' > "$TEMP/Content/Combat/DA_CombatBalance.uasset"
printf 'binary fixture\n' > "$TEMP/Content/Maps/Arena.umap"

python - "$ROOT" "$TEMP" <<'PY'
import json,sys
from pathlib import Path
sys.path.insert(0,str(Path(sys.argv[1])/"collectors")); from unreal_analysis import analyze_unreal
root=Path(sys.argv[2]); files=[{"path":p.relative_to(root).as_posix()} for p in root.rglob("*") if p.is_file()]
data=analyze_unreal(root,files,{"_file_author_activity":{}})
assert data["status"]=="assessed" and data["project"]["engine_association"]=="5.4"
assert data["modules"][0]["public_dependencies"]==["Core","CoreUObject","Engine","GameplayAbilities"]
assert data["targets"][0]["type"]=="Game" and data["plugins"][0]["enabled_by_default"] is True
assert data["summary"]["reflected_types"]>=1 and data["summary"]["blueprint_assets"]==2 and data["summary"]["maps"]==1
assert data["input"]["count"]==1 and data["tests"]["automation_macros"]==1
assert any(x["name"]=="Combat" for x in data["gameplay_systems"])
kinds={x["type"] for x in data["signals"]}; assert {"tick_enabled","actor_iteration","synchronous_asset_load"} <= kinds
(root/"report.json").write_text(json.dumps({"generic_analysis":{"analysis":{"unreal":data}}}),encoding="utf-8")
PY
python "$ROOT/renderers/unreal_reports.py" "$TEMP/report.json" "$TEMP/out" --schema "$ROOT/schemas/unreal-analysis-1.0.0.schema.json"
[[ -f "$TEMP/out/index.html" && -f "$TEMP/out/analysis.json" && -f "$TEMP/out/source_reflection.txt" ]]
grep -q 'Combat' "$TEMP/out/gameplay_systems.txt"
echo 'unreal analysis tests passed'
