import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_h5p/config.dart';
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
const Map<String, Map<String, dynamic>> h5pContent = {
  'h5purl1': {
    'url':
        'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Interactive%20Video.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9JbnRlcmFjdGl2ZSBWaWRlby5oNXAiLCJpYXQiOjE3NjE1MDM4NTksImV4cCI6MTc5MzAzOTg1OX0.qMAJYEY4IsrCjhQnFFlz2jA-H0OBJyJtXiwsj5nL35k',
    'title': 'Interactive Video',
    'icon': Icons.play_circle_filled,
    'color': Colors.purple,
  },
  'h5purl2': {
    'url':
        'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Test%20mcq.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9UZXN0IG1jcS5oNXAiLCJpYXQiOjE3NjE0OTk1OTMsImV4cCI6MTc5MzAzNTU5M30.Fb4dOMKXjTB47Ht1ot7PLcsw6qHbDWJ5FSZL8Q5Meq8',
    'title': 'Quiz Time',
    'icon': Icons.quiz,
    'color': Colors.orange,
  },
  'h5purl3': {
    'url':
        'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Course%20Presentation.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9Db3Vyc2UgUHJlc2VudGF0aW9uLmg1cCIsImlhdCI6MTc2MjA5MzYyMSwiZXhwIjoxNzkzNjI5NjIxfQ.uguBKJCrO3O1-lnt-DIFT3LBZrwL_oAoX7LK2VUgll8',
    'title': 'Presentation',
    'icon': Icons.slideshow,
    'color': Colors.blue,
  },
  'h5purl4': {
    'url':
        'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Example%20content%20-%20Arts%20of%20Europe.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9FeGFtcGxlIGNvbnRlbnQgLSBBcnRzIG9mIEV1cm9wZS5oNXAiLCJpYXQiOjE3NjIwOTM2NDgsImV4cCI6MTc5MzYyOTY0OH0.5XnGMY5n0jB4rynD8UcKTBAmAAN0bw1MnNdsrcX2qmg',
    'title': 'Arts Gallery',
    'icon': Icons.palette,
    'color': Colors.pink,
  },
};
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
        fontFamily: 'Comic Sans MS',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        debugPrint("📢 xAPI Event: $event");
      },
    );

    if (_isFullscreen) {
      return Scaffold(
        body: Stack(
          children: [
            webView,
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: GlassButton(
                  onPressed: _toggleFullscreen,
                  icon: Icons.fullscreen_exit,
                  color: Colors.red,
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
              Colors.purple.shade100,
              Colors.blue.shade100,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.pink.shade300,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Learning Adventure! 🚀",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _currentContentTitle ?? "Choose an activity",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Selection Cards
              Container(
                height: 140,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: h5pContent.length,
                  itemBuilder: (context, index) {
                    final entry = h5pContent.entries.elementAt(index);
                    return ContentCard(
                      title: entry.value['title'],
                      icon: entry.value['icon'],
                      color: entry.value['color'],
                      onTap: () {
                        _h5pcontroller.loadH5P(entry.value['url']);
                        setState(() {
                          _currentContentTitle = entry.value['title'];
                        });
                        _animationController.forward(from: 0);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Loading Status
              ValueListenableBuilder<H5PLoadStatus>(
                valueListenable: _h5pcontroller.status,
                builder: (_, status, __) {
                  if (status == H5PLoadStatus.downloading) {
                    return GlassContainer(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.download,
                                color: Colors.purple.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Downloading magic... ✨",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<double>(
                            valueListenable: _h5pcontroller.downloadProgress,
                            builder: (_, progress, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.purple.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.purple.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (status == H5PLoadStatus.extracting) {
                    return GlassContainer(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.unarchive,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Preparing your activity... 🎨",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ValueListenableBuilder<double>(
                            valueListenable: _h5pcontroller.downloadProgress,
                            builder: (_, progress, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.purple.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // WebView Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        webView,
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: GlassButton(
                            onPressed: _toggleFullscreen,
                            icon: Icons.fullscreen,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ContentCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Glassmorphism overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
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

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.7),
            Colors.white.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.5),
                Colors.white.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color.withValues(alpha: 0.7), size: 28),
        ),
      ),
    );
  }
}
