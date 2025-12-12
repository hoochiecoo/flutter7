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
      title: 'Hybrid Clean',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
      ..loadHtmlString('<html><body style="display:flex;justify-content:center;align-items:center;height:100vh;"><h1>Вебвью HTML</h1></body></html>');
  }

  Future<void> _launchNative() async {
    try {
      await platform.invokeMethod('openNativeScreen');
    } on PlatformException catch (e) {
      debugPrint("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clean Hybrid"), backgroundColor: Colors.blueAccent),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Center(child: Text("1. Flutter Screen", style: TextStyle(fontSize: 24))),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Открыть Native Activity (Kotlin)"),
              onPressed: _launchNative,
            ),
          ),
          WebViewWidget(controller: _webController),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Flutter'),
          BottomNavigationBarItem(icon: Icon(Icons.android), label: 'Native'),
          BottomNavigationBarItem(icon: Icon(Icons.web), label: 'Web'),
        ],
      ),
    );
  }
}
