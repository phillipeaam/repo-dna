#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/app/src/main/java/com/example/data" "$TMP/app/src/main/java/com/example/network" "$TMP/app/src/main/res/layout" "$TMP/app/src/main/res/navigation" "$TMP/app/src/test/java" "$TMP/app/src/androidTest/java"
cat > "$TMP/app/src/main/AndroidManifest.xml" <<'XML'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"><uses-permission android:name="android.permission.INTERNET"/><application><activity android:name=".MainActivity" android:exported="true"><intent-filter/></activity><service android:name=".SyncService"/><receiver android:name=".PushReceiver"/><provider android:name=".DataProvider"/></application></manifest>
XML
cat > "$TMP/build.gradle" <<'GRADLE'
plugins { id 'com.android.application' }
android {
  buildTypes {
    debug { }
    release { minifyEnabled true }
  }
  productFlavors {
    demo { dimension 'client' }
    production { dimension 'client' }
  }
}
dependencies {
 implementation 'androidx.room:room-runtime:2.7.0'
 implementation 'com.squareup.retrofit2:retrofit:2.11.0'
 implementation 'com.squareup.okhttp3:okhttp:4.12.0'
 implementation 'io.realm:realm-android-library:10.19.0'
 implementation 'com.google.android.gms:play-services-base:18.5.0'
 implementation 'com.google.code.gson:gson:2.12.0'
}
GRADLE
printf '<LinearLayout />' > "$TMP/app/src/main/res/layout/activity_main.xml"; printf '<navigation />' > "$TMP/app/src/main/res/navigation/main_nav.xml"
for file in MainActivity.kt HomeFragment.kt MainViewModel.kt ItemAdapter.kt; do printf 'class %s' "${file%.kt}" > "$TMP/app/src/main/java/com/example/$file"; done
printf 'class UserRepository' > "$TMP/app/src/main/java/com/example/data/UserRepository.kt"; printf 'class ApiService' > "$TMP/app/src/main/java/com/example/network/ApiService.kt"
printf 'class UnitTest' > "$TMP/app/src/test/java/UnitTest.kt"; printf 'class UiTest' > "$TMP/app/src/androidTest/java/UiTest.kt"
PYTHONPATH="$ROOT/collectors" python - "$TMP" "$ROOT" <<'PY'
import json, sys
from pathlib import Path
from android_analysis import analyze_android
root=Path(sys.argv[1]); files=[]; symbols=[]
for path in root.rglob('*'):
 if path.is_file():
  rel=path.relative_to(root).as_posix(); lang='Kotlin' if rel.endswith('.kt') else None; files.append({'path':rel,'language':lang,'lines':1})
  if lang: symbols.append({'path':rel,'name':path.stem,'language':lang})
activity={item['path']:{'Alice':{'commits':3}} for item in files if item.get('language')}
result=analyze_android(root,files,{'symbols':symbols,'imports':[]},{'_file_author_activity':activity})
assert result['status']=='assessed' and result['permissions']==['android.permission.INTERNET']
types={item['type'] for item in result['components']}; assert {'Activity','Service','BroadcastReceiver','ContentProvider','Fragment','ViewModel','Repository','Adapter'} <= types
assert result['summary']['layouts']==1 and result['summary']['unit_tests']==1 and result['summary']['instrumented_tests']==1
assert result['data_layer']['technologies']=={'SQLite':False,'Room':True,'Realm':True}
assert result['networking']['technologies']['Retrofit'] and result['networking']['technologies']['OkHttp'] and result['networking']['technologies']['Google APIs']
assert set(result['gradle']['build_types'])=={'debug','release'} and set(result['gradle']['product_flavors'])=={'demo','production'}
assert set(result['gradle']['build_variants'])=={'demoDebug','demoRelease','productionDebug','productionRelease'}
report={'generic_analysis':{'analysis':{'android':result}}}; (root/'report.json').write_text(json.dumps(report),encoding='utf-8')
PY
python "$ROOT/renderers/android_reports.py" "$TMP/report.json" "$TMP/android" --schema "$ROOT/schemas/android-analysis-1.0.0.schema.json"
for file in components dependencies permissions screens data_layer networking build_variants; do [[ -s "$TMP/android/$file.txt" ]]; done
grep -q 'android.permission.INTERNET' "$TMP/android/permissions.txt"; grep -q 'demoRelease' "$TMP/android/build_variants.txt"; grep -q 'Retrofit: detected' "$TMP/android/networking.txt"
echo "Android analysis tests passed"
