#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/lib/screens" "$TMP/lib/state" "$TMP/assets/images" "$TMP/lib/l10n" "$TMP/android/app/src/main/kotlin" "$TMP/ios/Runner" "$TMP/ios/Runner.xcodeproj/xcshareddata/xcschemes" "$TMP/test" "$TMP/integration_test"
cat > "$TMP/pubspec.yaml" <<'YAML'
name: verified_flutter_app
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  flutter_riverpod: ^2.6.1
  intl: ^0.19.0
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  assets:
    - assets/images/
YAML
cat > "$TMP/lib/screens/home_page.dart" <<'DART'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class HomePage extends StatelessWidget {}
final route = GoRoute(path: '/home', builder: (_, __) => HomePage());
const channel = MethodChannel('com.example/learning');
DART
printf "%s\n" "import 'package:flutter_riverpod/flutter_riverpod.dart';" 'class AppState {}' > "$TMP/lib/state/app_state.dart"
printf '{}' > "$TMP/lib/l10n/app_en.arb"; printf 'arb-dir: lib/l10n' > "$TMP/l10n.yaml"; printf 'image' > "$TMP/assets/images/logo.png"
cat > "$TMP/android/app/build.gradle" <<'GRADLE'
android { productFlavors {
  demo { dimension 'environment' }
  production { dimension 'environment' }
} }
GRADLE
printf '%s' 'MethodChannel(engine.dartExecutor.binaryMessenger, "com.example/learning")' > "$TMP/android/app/src/main/kotlin/MainActivity.kt"
printf '%s' 'FlutterMethodChannel(name: "com.example/learning")' > "$TMP/ios/Runner/AppDelegate.swift"
printf '<Scheme />' > "$TMP/ios/Runner.xcodeproj/xcshareddata/xcschemes/Demo.xcscheme"
printf 'void main() {}' > "$TMP/lib/main_demo.dart"; printf 'void main() {}' > "$TMP/test/home_test.dart"; printf 'void main() {}' > "$TMP/integration_test/app_test.dart"
PYTHONPATH="$ROOT/collectors" python - "$TMP" <<'PY'
import sys
from pathlib import Path
from flutter_analysis import analyze_flutter
root=Path(sys.argv[1]); files=[]
for path in root.rglob('*'):
 if path.is_file():
  rel=path.relative_to(root).as_posix(); files.append({'path':rel,'language':'Dart' if rel.endswith('.dart') else None,'lines':len(path.read_text(errors='ignore').splitlines())})
git={'_file_author_activity':{'lib/screens/home_page.dart':{'Alice':{'commits':7}}}}
result=analyze_flutter(root,files,git)
assert result['status']=='assessed' and 'provider' in result['dependencies']['runtime']
assert result['widgets'][0]['name']=='HomePage' and result['widgets'][0]['git_commit_touches']==7
assert result['screens'][0]['name']=='HomePage' and result['routes'][0]['route']=='/home'
state={item['name']:item for item in result['state_management']}; assert state['Provider']['confidence']=='high' and state['Riverpod']['confidence']=='high'
assert result['localization']['arb_files']==['lib/l10n/app_en.arb'] and result['assets']==['assets/images/']
assert result['platform_channels'][0]['name']=='com.example/learning' and len(result['platform_channels'][0]['native_matches'])==2
assert result['tests']['unit']==['test/home_test.dart'] and result['tests']['integration']==['integration_test/app_test.dart']
assert result['flavors']['android']==['demo','production'] and result['flavors']['dart_entrypoints']==['lib/main_demo.dart']
PY
python - "$TMP" <<'PY'
import json,sys
from pathlib import Path
sys.path.insert(0,str(Path.cwd()/'collectors'))
from flutter_analysis import analyze_flutter
root=Path(sys.argv[1]); files=[{'path':p.relative_to(root).as_posix(),'language':'Dart' if p.suffix=='.dart' else None,'lines':1} for p in root.rglob('*') if p.is_file()]
result=analyze_flutter(root,files,{'_file_author_activity':{}}); (root/'report.json').write_text(json.dumps({'generic_analysis':{'analysis':{'flutter':result}}}),encoding='utf-8')
PY
python "$ROOT/renderers/flutter_reports.py" "$TMP/report.json" "$TMP/flutter" --schema "$ROOT/schemas/flutter-analysis-1.0.0.schema.json"
for file in dependencies widgets screens_routes state_management localization_assets platform_channels tests_flavors; do [[ -s "$TMP/flutter/$file.txt" ]]; done
grep -q 'HomePage' "$TMP/flutter/widgets.txt"; grep -q 'com.example/learning' "$TMP/flutter/platform_channels.txt"; grep -q 'production' "$TMP/flutter/tests_flavors.txt"
echo "Flutter analysis tests passed"
