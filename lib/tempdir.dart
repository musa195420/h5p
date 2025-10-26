import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Copies the entire 'web' folder (including all subfolders and files) to local storage.
Future<String> copyWebFolder() async {
  final directory = await getApplicationDocumentsDirectory();
  final localPath = '${directory.path}/web_assets';

  await Directory(localPath).create(recursive: true);

  final files = [
    'index.html',
    'h5p.css',
    'frame.bundle.js',
    'jquery-3.2.0.min.js',
    'main.bundle.js',
    'final/h5p.json',
    'final/content/content.json',
    'final/FontAwesome-4.5/fontawesome-webfont.eot',
    'final/FontAwesome-4.5/fontawesome-webfont.svg',
    'final/FontAwesome-4.5/fontawesome-webfont.ttf',
    'final/FontAwesome-4.5/fontawesome-webfont.woff',
  ];

  for (var file in files) {
    await copyAssetFile('assets/web/$file', '$localPath/$file');
  }

  return localPath;
}

/// Copies a single asset file from the Flutter project to the local storage.
Future<void> copyAssetFile(String assetPath, String targetPath) async {
  try {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    final targetFile = File(targetPath);
    await targetFile.create(recursive: true);
    await targetFile.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
  } catch (e) {
    print('Error copying asset: $assetPath -> $e');
  }
}
