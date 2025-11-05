# 📜 Changelog

All notable changes to this project will be documented in this file.

---

## [1.0.0+2] - 2025-11-05

### 🚀 Added

- Introduced **`LumiH5PController`** for improved lifecycle management of H5P content.
- Added **download progress tracking** using `ValueListenableBuilder<double>` for real-time UI updates.
- Added **H5P content loading control** — easily start, stop, or reload H5P packages from URLs or local paths.
- Added **helper utilities** for preloading assets and managing cache.

### 🧩 Improved

- Enhanced **download reliability** and UI responsiveness during asset fetching.
- Optimized **asset copying** process from bundled resources to temporary directories.
- Improved **local web server handling** for H5P content serving.
- Enhanced **error handling and debug logging** for failed downloads or missing assets.

### 🧰 Internal

- Code refactoring for better maintainability and separation of logic.
- Improved null safety and controller checks before content rendering.
- Updated documentation and README examples.

---

## [1.0.0] - 2025-11-01

### 🎉 Initial Release

- Basic support for loading and displaying **H5P interactive content** locally.
- Local server setup to serve unzipped H5P files.
- Support for both **local assets** and **downloaded packages**.
- Example app included demonstrating simple content playback.
