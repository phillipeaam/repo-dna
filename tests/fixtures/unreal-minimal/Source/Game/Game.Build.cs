using UnrealBuildTool;
public class Game : ModuleRules { public Game(ReadOnlyTargetRules Target) : base(Target) { PublicDependencyModuleNames.AddRange(new string[] { "Core", "Engine" }); } }
