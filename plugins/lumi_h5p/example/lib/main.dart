import 'package:flutter/material.dart';
import 'package:lumi_h5p/controllers/h5p_controller.dart';

const Map<String, String> h5pUrls = {
  'h5purl1':
      'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Interactive%20Video.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9JbnRlcmFjdGl2ZSBWaWRlby5oNXAiLCJpYXQiOjE3NjE1MDM4NTksImV4cCI6MTc5MzAzOTg1OX0.qMAJYEY4IsrCjhQnFFlz2jA-H0OBJyJtXiwsj5nL35k',
  'h5purl2':
      'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Test%20mcq.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9UZXN0IG1jcS5oNXAiLCJpYXQiOjE3NjE0OTk1OTMsImV4cCI6MTc5MzAzNTU5M30.Fb4dOMKXjTB47Ht1ot7PLcsw6qHbDWJ5FSZL8Q5Meq8',
  'h5purl3':
      'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Course%20Presentation.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9Db3Vyc2UgUHJlc2VudGF0aW9uLmg1cCIsImlhdCI6MTc2MjA5MzYyMSwiZXhwIjoxNzkzNjI5NjIxfQ.uguBKJCrO3O1-lnt-DIFT3LBZrwL_oAoX7LK2VUgll8',
  'h5purl4':
      'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Example%20content%20-%20Arts%20of%20Europe.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9FeGFtcGxlIGNvbnRlbnQgLSBBcnRzIG9mIEV1cm9wZS5oNXAiLCJpYXQiOjE3NjIwOTM2NDgsImV4cCI6MTc5MzYyOTY0OH0.5XnGMY5n0jB4rynD8UcKTBAmAAN0bw1MnNdsrcX2qmg',
};

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
