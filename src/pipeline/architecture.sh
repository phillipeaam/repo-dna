collect_architecture() {
log_info "Detecting architecture, systems, and technologies"

local system_keywords
system_keywords="$(system_keywords_pattern)"

# Run C#-specific architecture analysis only for C# project profiles.
if [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]]; then
# Detect ScriptableObjects.
analysis_grep \
    --include='*.cs' \
    -InE \
    'CreateAssetMenu|:[[:space:]]*ScriptableObject' \
    > "$PROJECT_DIR/13_scriptable_objects.txt"

# Detect MonoBehaviours.
analysis_grep \
    --include='*.cs' \
    -InE \
    ':[[:space:]]*MonoBehaviour' \
    > "$PROJECT_DIR/14_monobehaviours.txt"

# Detect interfaces.
analysis_grep \
    --include='*.cs' \
    -InE \
    '^[[:space:]]*(public|internal|protected|private)?[[:space:]]*interface[[:space:]]+' \
    > "$PROJECT_DIR/15_interfaces.txt"

# Detect custom editor tooling.
analysis_grep \
    --include='*.cs' \
    -InE \
    'UnityEditor|CustomEditor|PropertyDrawer|EditorWindow|MenuItem' \
    > "$PROJECT_DIR/16_editor_tooling.txt"

# Detect likely gameplay and product-system files by file name.
analysis_find -type f -iname '*.cs' -print 2>/dev/null |
    grep -Ei "$system_keywords" |
    sort \
    > "$PROJECT_DIR/17_likely_system_files.txt" || true

# Detect common architecture patterns.
analysis_grep \
    --include='*.cs' \
    -InE \
    'Singleton|StateMachine|IState|Command|Observer|EventBus|ServiceLocator|DependencyInjection|Factory|Builder|Strategy|ObjectPool|Repository|Mediator|MVC|MVVM|Presenter' \
    > "$PROJECT_DIR/18_architecture_pattern_signals.txt"

# Detect networking technologies.
analysis_grep \
    --include='*.cs' \
    -InEi \
    'Photon|Mirror|Fusion|Netcode|NetworkBehaviour|NetworkObject|RPC|ClientRpc|ServerRpc|Bolt|FishNet|Steamworks' \
    > "$PROJECT_DIR/19_networking_signals.txt"

# Detect backend and data integrations.
analysis_grep \
    --include='*.cs' \
    -InEi \
    'HttpClient|UnityWebRequest|REST|GraphQL|Firebase|Analytics|Telemetry|WebSocket|Socket|API|JsonUtility|Newtonsoft|SQLite|LiteDB|Realm' \
    > "$PROJECT_DIR/20_services_and_data_signals.txt"

# Detect performance-related techniques.
analysis_grep \
    --include='*.cs' \
    -InEi \
    'Profiler|ObjectPool|pooling|Addressables|async|await|Task|JobHandle|BurstCompile|NativeArray|ECS|EntityManager|GC\.Alloc|Resources\.Unload|AssetBundle' \
    > "$PROJECT_DIR/21_performance_signals.txt"

# Detect technical-debt markers.
analysis_grep \
    --include='*.cs' \
    -InE \
    'TODO|FIXME|HACK|XXX' \
    > "$PROJECT_DIR/22_technical_debt_markers.txt"
fi

# Print the fourth progress step.
}
