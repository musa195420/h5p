import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_h5p/config.dart';
import 'package:lumi_h5p/controllers/h5p_controller.dart';
import 'package:lumi_h5p/models/h5p_request_model.dart';
import 'package:test_h5p/constants.dart';

const Map<String, String> h5pUrls = {
  'h5purl1': h5pUrl1,
  'h5purl2': h5pUrl2,
  'h5purl3': h5pUrl3,
  'h5purl4': h5pUrl4,
};

const Map<String, Map<String, dynamic>> h5pContent = {
  'h5purl1': {
    'url': h5pUrl1,
    'title': ' Video',
    'subtitle': 'Watch & Learn',
    'icon': Icons.play_circle_filled,
    'color': Color(0xFF9C27B0), // Purple
  },
  'h5purl2': {
    'url': h5pUrl2,
    'title': 'Quiz Time',
    'subtitle': 'Test Your Knowledge',
    'icon': Icons.quiz_outlined,
    'color': Color(0xFFFF9800), // Orange
  },
  'h5purl3': {
    'url': h5pUrl3,
    'title': 'Course Slides',
    'subtitle': 'Learn Step by Step',
    'icon': Icons.slideshow,
    'color': Color(0xFF2196F3), // Blue
  },
  'h5purl4': {
    'url': h5pUrl4,
    'title': 'Arts Gallery',
    'subtitle': 'Explore & Discover',
    'icon': Icons.palette,
    'color': Color(0xFFE91E63), // Pink
  },
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const TestView(),
    );
  }
}

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> with TickerProviderStateMixin {
  final LumiH5PController _h5pcontroller = LumiH5PController();
  bool _isFullscreen = false;
  String? _currentContentTitle;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _h5pcontroller.addRequestList(h5pmodels);
    h5pDebug = false;
    h5pError = false;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    H5pWebView webView = H5pWebView(
      controller: _h5pcontroller,
      listenToEvents: true,
      onXApiEvent: (event) {
        h5pLog(message: "📢 xAPI Event: $event");
      },
    );

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            webView,
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _toggleFullscreen,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildContentCards(),
              const SizedBox(height: 12),
              _buildLoadingStatus(),
              _buildWebViewContainer(webView),
              _buildRequestsList(),
              _buildAddMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple.shade400, Colors.pink.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Learning Hub 🚀",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentContentTitle ?? "Choose an activity to start",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCards() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: h5pContent.length,
        itemBuilder: (context, index) {
          final entry = h5pContent.entries.elementAt(index);
          return _ContentCard(
            title: entry.value['title'],
            subtitle: entry.value['subtitle'],
            icon: entry.value['icon'],
            color: entry.value['color'],
            onTap: () {
              _h5pcontroller.loadH5P(entry.value['url']);
              setState(() {
                _currentContentTitle = entry.value['title'];
              });
              _slideController.forward(from: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingStatus() {
    return ValueListenableBuilder<H5PLoadStatus>(
      valueListenable: _h5pcontroller.status,
      builder: (_, status, __) {
        if (status == H5PLoadStatus.downloading) {
          return _LoadingCard(
            icon: Icons.download_rounded,
            message: "Downloading content... ✨",
            color: Colors.purple,
            controller: _h5pcontroller,
            showProgress: true,
          );
        } else if (status == H5PLoadStatus.extracting) {
          return _LoadingCard(
            icon: Icons.folder_zip_rounded,
            message: "Preparing your activity... 🎨",
            color: Colors.blue,
            controller: _h5pcontroller,
            showProgress: false,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWebViewContainer(Widget webView) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.2),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(color: Colors.white, child: webView),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _toggleFullscreen,
                  backgroundColor: Colors.purple.shade400,
                  elevation: 8,
                  child: const Icon(Icons.fullscreen, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return ValueListenableBuilder<List<H5PRequestModel>>(
      valueListenable: _h5pcontroller.requests,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 150),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Downloads",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final req = list[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(req.status),
                            size: 20,
                            color: _getStatusColor(req.status),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              req.refName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                req.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              req.status.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(req.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          _h5pcontroller.addRequestList(moreh5pmodels);
        },
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("Load More Activities"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
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

  Color _getStatusColor(H5PFileStatus status) {
    switch (status) {
      case H5PFileStatus.downloading:
        return Colors.blue;
      case H5PFileStatus.downloaded:
        return Colors.green;
      case H5PFileStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ContentCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 180,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color, widget.color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  widget.icon,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final LumiH5PController controller;
  final bool showProgress;

  const _LoadingCard({
    required this.icon,
    required this.message,
    required this.color,
    required this.controller,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ValueListenableBuilder<double>(
            valueListenable: showProgress
                ? controller.downloadProgress
                : controller.extractprogress,
            builder: (_, progress, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
