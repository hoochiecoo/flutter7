import 'dart:io';

void main() {
  print('🚀 Starting Native Setup (Debug Mode)...');

  final packagePath = 'android/app/src/main/kotlin/com/example/hybrid';
  final mainActivityPath = '$packagePath/MainActivity.kt';
  final nativeActivityPath = '$packagePath/NativeActivity.kt';
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final gradlePath = 'android/app/build.gradle';

  Directory(packagePath).createSync(recursive: true);

  // MainActivity с отловом ошибок
  File(mainActivityPath).writeAsStringSync('''
package com.example.hybrid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.widget.Toast

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
                    // Возвращаем ошибку во Flutter, чтобы показать диалог
                    result.error("NATIVE_ERR", e.message, e.stackTraceToString())
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
''');
  print('✅ MainActivity.kt generated');

  // NativeActivity
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
        layout.setBackgroundColor(Color.parseColor("#212121"))

        val text = TextView(this)
        text.text = "SUCCESS!\nNative Activity"
        text.textSize = 30f
        text.setTextColor(Color.GREEN)
        text.gravity = Gravity.CENTER
        layout.addView(text)
        
        setContentView(layout)
    }
}
''');
  print('✅ NativeActivity.kt generated');

  // МАНИФЕСТ: Используем </application> как якорь
  final manifestFile = File(manifestPath);
  if (manifestFile.existsSync()) {
    var content = manifestFile.readAsStringSync();
    
    // Удаляем старые попытки (если были)
    if (content.contains('NativeActivity')) {
       print('⚠️ Manifest already has NativeActivity');
    } else {
      // Вставляем ПЕРЕД закрывающим тегом application
      if (content.contains('</application>')) {
         content = content.replaceFirst(
            '</application>', 
            '    <activity android:name=".NativeActivity" android:label="Native Screen" android:theme="@android:style/Theme.NoTitleBar" />\n    </application>'
         );
         manifestFile.writeAsStringSync(content);
         print('✅ AndroidManifest.xml patched correctly (inside application tag)');
      } else {
         print('❌ ERROR: Could not find </application> tag in Manifest!');
         exit(1);
      }
    }
  }

  // Gradle
  final gradleFile = File(gradlePath);
  if (gradleFile.existsSync()) {
    var content = gradleFile.readAsStringSync();
    content = content.replaceAll(RegExp(r'minSdkVersion .*'), 'minSdkVersion 21');
    gradleFile.writeAsStringSync(content);
    print('✅ build.gradle patched');
  }
}
