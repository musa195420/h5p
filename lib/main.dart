import 'package:flutter/material.dart';
import 'package:lumi_h5p/example/test_view.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const LocalWebView(urlMap: h5pUrls),
    );
  }
}
