// tempdir.dart
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Handles setup of the H5P environment.
class H5PSetup {
  final Dio _dio = Dio();

  /// Copies the base H5P player files (HTML, JS, CSS) from assets to local folder.
  Future<String> copyBaseFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final finalDir = Directory('${dir.path}/base');
    await finalDir.create(recursive: true);

    final baseFiles = [
      'index.html',
      'h5p.css',
      'frame.bundle.js',
      'jquery-3.2.0.min.js',
      'main.bundle.js',
    ];

    for (final fileName in baseFiles) {
      await _copyAssetFile(
          'assets/web/$fileName', '${finalDir.path}/$fileName');
    }

    debugPrint('✅ Base files copied to: ${finalDir.path}');
    return finalDir.path;
  }

  Future<String> downloadFileForLater(String url, String refName) async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/downloads');
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }

    final filePath = '${downloadDir.path}/$refName.h5p';
    final file = File(filePath);

    await _dio.download(url, file.path, onReceiveProgress: (received, total) {
      if (total != -1) {
        final progress = (received / total * 100).toStringAsFixed(0);
        debugPrint("⬇️ $refName → $progress%");
      }
    });

    return file.path;
  }

  Future<String> downloadH5P(String url, {Function(double)? onProgress}) async {
    final dir = await getApplicationDocumentsDirectory();
    final tempH5p = File('${dir.path}/temp.h5p');

    debugPrint('⬇️ Downloading H5P from $url ...');
    await _dio.download(url, tempH5p.path,
        onReceiveProgress: (received, total) {
      if (total != -1 && onProgress != null) {
        onProgress(received / total);
      }
    });

    return tempH5p.path;
  }

  /// Extracts .h5p/.zip to final folder with optional progress callback
  Future<void> extractH5P(String zipPath,
      {Function(double)? onProgress}) async {
    final dir = await getApplicationDocumentsDirectory();
    final extractPath = '${dir.path}/base/final';

    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    int totalFiles = archive.length;
    int processedFiles = 0;

    for (final file in archive) {
      final filename = '$extractPath/${file.name}';
      if (file.isFile) {
        final outFile = File(filename)..createSync(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        Directory(filename).createSync(recursive: true);
      }
      processedFiles++;
      if (onProgress != null) {
        onProgress(processedFiles / totalFiles);
      }
    }

    debugPrint('✅ Extraction done → $extractPath');
  }

  /// Downloads a `.h5p` file, renames it to `.zip`, extracts to `/final`.
  Future<void> downloadAndExtract(String url,
      {Function(double)? onProgress}) async {
    final dir = await getApplicationDocumentsDirectory();
    final tempH5p = File('${dir.path}/temp.h5p');
    final tempZip = File('${dir.path}/temp.zip');
    final extractPath = '${dir.path}/base/final';

    // Download .h5p file with progress callback
    debugPrint('⬇️ Downloading H5P from $url ...');
    await _dio.download(url, tempH5p.path,
        onReceiveProgress: (received, total) {
      if (total != -1 && onProgress != null) {
        onProgress((received / total));
      }
    });

    // Rename to .zip
    if (await tempZip.exists()) await tempZip.delete();
    await tempH5p.rename(tempZip.path);

    // Extract
    debugPrint('📦 Extracting H5P ...');
    final bytes = await tempZip.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = '$extractPath/${file.name}';
      if (file.isFile) {
        final outFile = File(filename)..createSync(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        Directory(filename).createSync(recursive: true);
      }
    }

    debugPrint('✅ Extraction done → $extractPath');
  }

  Future<void> _copyAssetFile(String assetPath, String targetPath) async {
    try {
      // Ensure plugin asset prefix
      final pluginAssetPath = 'packages/lumi_h5p/$assetPath';

      final byteData = await rootBundle.load(pluginAssetPath);
      final file = File(targetPath);
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));
    } catch (e) {
      debugPrint('⚠️ Failed to copy asset: $assetPath → $e');
    }
  }
}
