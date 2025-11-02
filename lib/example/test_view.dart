
import 'package:flutter/material.dart';
import 'package:virtualh5p/constants.dart';
import 'package:virtualh5p/h5p_loader.dart';
import 'package:virtualh5p/local_web_view.dart';
import 'package:virtualh5p/config.dart';

class LocalWebView extends StatefulWidget {
  const LocalWebView({super.key});

  @override
  LocalWebViewState createState() => LocalWebViewState();
}

class LocalWebViewState extends State<LocalWebView> {
  final H5PLoader _loader = H5PLoader();

  @override
  void initState() {
    super.initState();
    _loader.prepareBaseFiles();
  }

  @override
  void dispose() {
    _loader.closeServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("H5P Local Viewer"),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[50],
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: urls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return ValueListenableBuilder<bool>(
                  valueListenable: _loader.isLoading,
                  builder: (_, isLoading, __) {
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _loader.loadH5P(url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Load H5P ${index + 1}'),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Status Indicator
          ValueListenableBuilder<H5PLoadStatus>(
            valueListenable: _loader.status,
            builder: (_, status, __) {
              Color color;
              IconData icon;
              switch (status) {
                case H5PLoadStatus.downloading:
                  color = Colors.orange;
                  icon = Icons.download;
                  break;
                case H5PLoadStatus.extracting:
                  color = Colors.amber;
                  icon = Icons.folder_open;
                  break;
                case H5PLoadStatus.ready:
                  color = Colors.green;
                  icon = Icons.check_circle;
                  break;
                case H5PLoadStatus.error:
                  color = Colors.red;
                  icon = Icons.error;
                  break;
                default:
                  color = Colors.grey;
                  icon = Icons.hourglass_empty;
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 40,
                color: color.withAlpha(1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(status.H5PLABEL, style: TextStyle(color: color)),
                  ],
                ),
              );
            },
          ),

          // Download Progress Bar
          ValueListenableBuilder<double>(
            valueListenable: _loader.downloadProgress,
            builder: (_, value, __) {
              if (value > 0 && value < 1) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.orange),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // WebView
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: _loader.localServerUrl,
              builder: (context, url, _) {
                if (url == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.launch, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Select an H5P file to load",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return LocalH5PWebView(
                  url: url,
                  onWebViewCreated: (controller) {},
                  onPageLoaded: () {
                    debugPrint("✅ H5P fully loaded in webview");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
