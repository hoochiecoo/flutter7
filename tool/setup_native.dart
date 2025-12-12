import 'dart:io';

void main() {
  print('🚀 Starting Native Setup...');

  // 1. Пути к файлам
  final packagePath = 'android/app/src/main/kotlin/com/example/hybrid';
  final mainActivityPath = '$packagePath/MainActivity.kt';
  final nativeActivityPath = '$packagePath/NativeActivity.kt';
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final gradlePath = 'android/app/build.gradle';

  // 2. Создаем структуру папок (если flutter create ее не доделал или сделал иначе)
  Directory(packagePath).createSync(recursive: true);

  // 3. Записываем MainActivity.kt
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
                val intent = Intent(this, NativeActivity::class.java)
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
''');
  print('✅ MainActivity.kt generated');

  // 4. Записываем NativeActivity.kt
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
        layout.setBackgroundColor(Color.BLACK)

        val text = TextView(this)
        text.text = "ЭТО НАТИВ (KOTLIN)"
        text.textSize = 30f
        text.setTextColor(Color.GREEN)
        layout.addView(text)
        
        setContentView(layout)
    }
}
''');
  print('✅ NativeActivity.kt generated');

  // 5. Обновляем AndroidManifest.xml (Добавляем Activity)
  final manifestFile = File(manifestPath);
  if (manifestFile.existsSync()) {
    var content = manifestFile.readAsStringSync();
    if (!content.contains('NativeActivity')) {
      // Вставляем новую активити после закрытия главной
      content = content.replaceFirst(
        '</activity>', 
        '</activity>\n        <activity android:name=".NativeActivity" android:label="Native" />'
      );
      manifestFile.writeAsStringSync(content);
      print('✅ AndroidManifest.xml patched');
    }
  }

  // 6. Обновляем build.gradle (minSdkVersion)
  final gradleFile = File(gradlePath);
  if (gradleFile.existsSync()) {
    var content = gradleFile.readAsStringSync();
    content = content.replaceAll(RegExp(r'minSdkVersion .*'), 'minSdkVersion 21');
    gradleFile.writeAsStringSync(content);
    print('✅ build.gradle patched (minSdk 21)');
  }

  print('🎉 Native setup complete!');
}
