# 📜 Changelog

All notable changes to this project will be documented in this file.

---

## [1.0.6] - 2025-11-17

### 🚀 Added

- Introduced **`LumiH5PController`** for managing the full H5P content lifecycle (loading, refreshing, reusing).
- Added **download progress tracking** with `ValueListenableBuilder<double>` to reflect live download status in the UI.
- Added **H5P loading control methods** — easily start, stop, or reload content from both URLs and local paths.
- Added **helper utilities** for handling asset extraction, caching, and setup for local web serving.

### 🧩 Improved

- Enhanced **download reliability** for large H5P packages.
- Optimized **asset copying** from the Flutter bundle to the temporary directory.
- Improved **local web server performance** and content availability.
- Added **comprehensive error logs** and safe null checks to prevent crashes.

### 🧰 Internal

- Major code refactoring for cleaner architecture and maintainability.
- Updated documentation and README with clearer examples.
