import 'dart:io';

void main() {
  print('🚀 Starting Native Setup (Fixed Mode)...');

  final packagePath = 'android/app/src/main/kotlin/com/example/hybrid';
  final mainActivityPath = '$packagePath/MainActivity.kt';
  final nativeActivityPath = '$packagePath/NativeActivity.kt';
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final gradlePath = 'android/app/build.gradle';

  Directory(packagePath).createSync(recursive: true);

  // MainActivity
  File(mainActivityPath).writeAsStringSync('''
package com.example.hybrid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.hybrid/nav"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "openNativeScreen") {
                try {
                    val intent = Intent(this, NativeActivity::class.java)
                    startActivity(intent)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("NATIVE_ERR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
''');
  print('✅ MainActivity.kt generated');

  // NativeActivity - ИСПРАВЛЕНО: Текст в одну строку, чтобы не ломать компилятор
  File(nativeActivityPath).writeAsStringSync('''
package com.example.hybrid

import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color

class NativeActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL
        layout.gravity = Gravity.CENTER
        layout.setBackgroundColor(Color.parseColor("#333333"))

        val text = TextView(this)
        text.text = "NATIVE ACTIVITY WORKS" 
        text.textSize = 24f
        text.setTextColor(Color.GREEN)
        text.gravity = Gravity.CENTER
        layout.addView(text)
        
        setContentView(layout)
    }
}
''');
  print('✅ NativeActivity.kt generated');

  // MANIFEST PATCHING
  final manifestFile = File(manifestPath);
  if (manifestFile.existsSync()) {
    var content = manifestFile.readAsStringSync();
    if (!content.contains('NativeActivity')) {
      if (content.contains('</application>')) {
         // Вставляем строго перед закрывающим тегом
         content = content.replaceFirst(
            '</application>', 
            '    <activity android:name=".NativeActivity" android:theme="@android:style/Theme.NoTitleBar" />\n    </application>'
         );
         manifestFile.writeAsStringSync(content);
         print('✅ AndroidManifest.xml patched');
      } else {
         print('❌ ERROR: </application> not found');
         exit(1);
      }
    }
  }

  // GRADLE PATCHING
  final gradleFile = File(gradlePath);
  if (gradleFile.existsSync()) {
    var content = gradleFile.readAsStringSync();
    content = content.replaceAll(RegExp(r'minSdkVersion .*'), 'minSdkVersion 21');
    gradleFile.writeAsStringSync(content);
    print('✅ build.gradle patched');
  }
}
