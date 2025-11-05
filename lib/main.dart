import 'package:flutter/material.dart';
import 'package:lumi_h5p/controllers/h5p_controller.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TestView());
  }
}

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  final LumiH5PController _h5pcontroller = LumiH5PController();

  @override
  Widget build(BuildContext context) {
    H5pWebView webView = H5pWebView(controller: _h5pcontroller);

    return Scaffold(
      appBar: AppBar(title: const Text("H5P Viewer Example")),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: h5pUrls.entries.map((entry) {
              return ElevatedButton(
                onPressed: () {
                  _h5pcontroller.loadH5P(entry.value);
                },
                child: Text(entry.key),
              );
            }).toList(),
          ),
          ValueListenableBuilder<double>(
            valueListenable: _h5pcontroller.downloadProgress,
            builder: (_, value, __) {
              if (value > 0 && value < 1) {
                return LinearProgressIndicator(value: value);
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(child: webView),
        ],
      ),
    );
  }
}
