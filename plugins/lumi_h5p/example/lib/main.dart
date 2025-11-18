import 'package:flutter/material.dart';
import 'package:lumi_h5p/config.dart';
import 'package:lumi_h5p/controllers/h5p_controller.dart';
import 'package:lumi_h5p/models/h5p_request_model.dart';

// priority url with their refnames
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
  H5PRequestModel(
    refName: 'h5purl1',
    url: h5pUrl1,
    priority: 6,
  ), // priority set it to be dowanloded first
  H5PRequestModel(refName: 'h5purl4', url: h5pUrl4, priority: 7),
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
  final Set<H5PRequestModel> _selectedRequests = {};
  final LumiH5PController _h5pcontroller = LumiH5PController();
  @override
  void initState() {
    _h5pcontroller.addRequestList(h5pmodels);
    //h5pDebug = true; // 👈 enable debug logs
    h5pError = true; // 👈 enable error logs
    //h5pPort=8050; // 👈 set custom port if needed

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
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: h5pUrls.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _h5pcontroller.loadH5P(url: entry.value);
                          },
                          child: Text(entry.key),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () {
                            _h5pcontroller.loadH5P(
                              url: entry.value,
                            ); //pass ref name only if already dwonlaoded
                          },
                          child: Text("Without Ref (${entry.key})"),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // -----------------------------
          // LOADER SECTION
          // -----------------------------
          ValueListenableBuilder<H5PLoadStatus>(
            valueListenable: _h5pcontroller.status,
            builder: (_, status, _) {
              if (status == H5PLoadStatus.downloading) {
                return Column(
                  children: [
                    const Text("Downloading..."),
                    ValueListenableBuilder<double>(
                      valueListenable: _h5pcontroller
                          .downloadProgress, //get progress of downloaded file
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
                      valueListenable: _h5pcontroller
                          .extractProgress, //get progress of extratced file
                      builder: (_, progress, _) => LinearProgressIndicator(
                        value: progress > 0 ? progress : null,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // -----------------------------
          // WEBVIEW
          // -----------------------------
          Expanded(child: webView),

          // -----------------------------
          // REQUEST LIST WITH SELECTION
          // -----------------------------
          SizedBox(
            height: 220,
            child: Column(
              children: [
                // REMOVE SELECTED BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          List<H5PRequestModel> selected = _selectedRequests
                              .toList();
                          if (selected.isNotEmpty) {
                            _h5pcontroller.addRequestList(
                              selected,
                              remove: true,
                            );
                            setState(() => _selectedRequests.clear());
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Remove Selected"),
                      ),

                      Spacer(),
                      TextButton(
                        onPressed: () {
                          _h5pcontroller
                              .clearAllRequests(); //remove all h5p files
                        },
                        child: Text("Clear ALL"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // LIST
                Expanded(
                  child: ValueListenableBuilder<List<H5PRequestModel>>(
                    valueListenable: _h5pcontroller.requests,
                    builder: (context, list, _) {
                      if (list.isEmpty) return const Text("No requests");

                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, index) {
                          final req = list[index];
                          final isSelected = _selectedRequests.contains(req);

                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (_) {
                                setState(() {
                                  isSelected
                                      ? _selectedRequests.remove(req)
                                      : _selectedRequests.add(req);
                                });
                              },
                            ),
                            title: Row(
                              children: [
                                Text(req.refName),
                                Spacer(),
                                Icon(_getStatusIcon(req.status)),
                              ],
                            ),
                            subtitle: Row(
                              children: [Text("Status: ${req.status.name}")],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _h5pcontroller.addRequest(
                                  req,
                                  remove: true,
                                ); // remove and clear memory
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () => _h5pcontroller.addRequestList(
              moreh5pmodels,
            ), //add more h5p files to download
            child: const Text("Add more H5P requests"),
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
