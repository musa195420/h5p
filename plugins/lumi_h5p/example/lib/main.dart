import 'package:flutter/material.dart';
import 'package:lumi_h5p/config.dart';
import 'package:lumi_h5p/controllers/h5p_controller.dart';
import 'package:lumi_h5p/models/h5p_request_model.dart';

const String h5pUrl1 =
    'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Interactive%20Video.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9JbnRlcmFjdGl2ZSBWaWRlby5oNXAiLCJpYXQiOjE3NjE1MDM4NTksImV4cCI6MTc5MzAzOTg1OX0.qMAJYEY4IsrCjhQnFFlz2jA-H0OBJyJtXiwsj5nL35k';
const String h5pUrl2 =
    'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Test%20mcq.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9UZXN0IG1jcS5oNXAiLCJpYXQiOjE3NjE0OTk1OTMsImV4cCI6MTc5MzAzNTU5M30.Fb4dOMKXjTB47Ht1ot7PLcsw6qHbDWJ5FSZL8Q5Meq8';
const String h5pUrl3 =
    'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Course%20Presentation.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9Db3Vyc2UgUHJlc2VudGF0aW9uLmg1cCIsImlhdCI6MTc2MjA5MzYyMSwiZXhwIjoxNzkzNjI5NjIxfQ.uguBKJCrO3O1-lnt-DIFT3LBZrwL_oAoX7LK2VUgll8';
const String h5pUrl4 =
    'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Example%20content%20-%20Arts%20of%20Europe.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9FeGFtcGxlIGNvbnRlbnQgLSBBcnRzIG9mIEV1cm9wZS5oNXAiLCJpYXQiOjE3NjIwOTM2NDgsImV4cCI6MTc5MzYyOTY0OH0.5XnGMY5n0jB4rynD8UcKTBAmAAN0bw1MnNdsrcX2qmg';

const Map<String, String> h5pUrls = {
  'h5purl1': h5pUrl1,
  'h5purl2': h5pUrl2,
  'h5purl3': h5pUrl3,
  'h5purl4': h5pUrl4,
};

List<H5PRequestModel> h5pmodels = [
  H5PRequestModel(refName: 'h5purl1', url: h5pUrl1),
  H5PRequestModel(refName: 'h5purl2', url: h5pUrl2),
];

List<H5PRequestModel> moreh5pmodels = [
  H5PRequestModel(refName: 'h5purl2', url: h5pUrl2),
  H5PRequestModel(refName: 'h5purl3', url: h5pUrl3),
  H5PRequestModel(refName: 'h5purl4', url: h5pUrl4),
];

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
  void initState() {
    _h5pcontroller.addRequestList(h5pmodels);
    h5pDebug = true; // 👈 enable debug logs
    h5pError = true; // 👈 enable error logs

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    H5pWebView webView = H5pWebView(
      controller: _h5pcontroller,
      listenToEvents:
          true, //only needed if you want to listen to events like marks and anything else
      onXApiEvent: (event) {
        h5pLog(message: "📢 xAPI Event: $event");
      },
    );
    return Scaffold(
      appBar: AppBar(title: const Text("H5P Viewer Example")),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: h5pUrls.entries.map((entry) {
              return ElevatedButton(
                onPressed: () {
                  _h5pcontroller.loadH5P(url: entry.value, refName: entry.key);
                },
                child: Text(entry.key),
              );
            }).toList(),
          ),
          ValueListenableBuilder<H5PLoadStatus>(
            valueListenable: _h5pcontroller.status,
            builder: (_, status, _) {
              if (status == H5PLoadStatus.downloading) {
                return Column(
                  children: [
                    const Text("Downloading..."),
                    ValueListenableBuilder<double>(
                      valueListenable: _h5pcontroller.downloadProgress,
                      builder: (_, progress, _) =>
                          LinearProgressIndicator(value: progress),
                    ),
                  ],
                );
              } else if (status == H5PLoadStatus.extracting) {
                return Column(
                  children: [
                    const Text("Extracting... Please wait"),
                    ValueListenableBuilder<double>(
                      valueListenable: _h5pcontroller.downloadProgress,
                      builder: (_, progress, _) => LinearProgressIndicator(
                        value: progress > 0
                            ? progress
                            : null, // indeterminate if 0
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(child: webView),
          ValueListenableBuilder<List<H5PRequestModel>>(
            valueListenable: _h5pcontroller.requests,
            builder: (context, list, _) {
              if (list.isEmpty) {
                return const Text("No requests");
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final req = list[index];

                  return ListTile(
                    leading: Icon(_getStatusIcon(req.status)),
                    title: Text(req.refName),

                    trailing: Text(req.status.name),
                  );
                },
              );
            },
          ),
          TextButton(
            onPressed: () {
              _h5pcontroller.addRequestList(moreh5pmodels);
            },
            child: Text("Add more H5P requests"),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(H5PFileStatus status) {
    switch (status) {
      case H5PFileStatus.undefined:
        return Icons.hourglass_empty;
      case H5PFileStatus.downloading:
        return Icons.downloading;

      case H5PFileStatus.downloaded:
        return Icons.check_circle;
      case H5PFileStatus.failed:
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
