import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hybrid Debug',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const platform = MethodChannel('com.example.hybrid/nav');
  late final WebViewController _webController;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString('<html><body style="display:flex;justify-content:center;align-items:center;height:100vh;"><h1>WebView OK</h1></body></html>');
  }

  Future<void> _launchNative() async {
    try {
      // Пытаемся вызвать натив
      await platform.invokeMethod('openNativeScreen');
    } on PlatformException catch (e) {
      // ЕСЛИ ОШИБКА - ПОКАЗЫВАЕМ ДИАЛОГ
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ошибка запуска Native"),
            content: Text("Код: ${e.code}\nСообщение: ${e.message}\nДетали: ${e.details}"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
       if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Неизвестная ошибка"),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug Hybrid"), backgroundColor: Colors.redAccent),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Flutter Screen", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  icon: const Icon(Icons.bug_report),
                  label: const Text("ЗАПУСТИТЬ NATIVE (DEBUG)"),
                  onPressed: _launchNative,
                ),
              ],
            ),
          ),
          const Center(child: Text("Заглушка для Native таба")),
          WebViewWidget(controller: _webController),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.android), label: 'Native Tab'),
          BottomNavigationBarItem(icon: Icon(Icons.web), label: 'Web'),
        ],
      ),
    );
  }
}
