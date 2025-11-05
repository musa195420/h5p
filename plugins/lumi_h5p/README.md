# 🎯 test_h5p

A new **Flutter package** that helps you **play Lumi H5P files locally** — no external H5P server required! 🚀

---

## 📱 About

**test_h5p** is designed to make it easy for developers and educators to **load, download, and play H5P interactive content** directly on their devices.  
This is especially useful for **schooling or offline learning scenarios**, where access to an H5P server may not be available.

---

## ✨ Features

✅ Play `.h5p` files **locally** on your device  
✅ **No need for an H5P server** or online rendering  
✅ Automatically downloads the `.h5p` file from a given URL  
✅ Future updates will include:

- 🔄 Background downloading of all H5P files using a **`HashMap<String, String>`**
- 💾 Seamless local playback using stored file references

---

## 🧩 How It Works

1. **Upload** your H5P file to **Lumi** (or any accessible online location).
2. **Provide the direct URL** of your H5P file to this package.
3. The package will:
   - 📦 Download the `.h5p` file
   - 🎮 Render and play it locally
4. Enjoy **offline interactive content** — completely **serverless**! 🌐❌

---

## 🆓 License & Usage

This package is **free to use** for **schooling and educational purposes**. 🏫  
Future versions may include more advanced offline management features.

---

## 🚀 Getting Started

You can integrate this package into your Flutter project by importing it and using the provided controller and widget.

---

## 💡 Example (Coming Soon)

Here’s a **basic usage example**:

```dart
// Import the package
import 'package:test_h5p/test_h5p.dart';

// Initialize the controller
LumiH5PController _h5pController = LumiH5PController();

// Create the WebView
H5pWebView webView = H5pWebView(controller: _h5pController);

// Example usage with a progress indicator
ValueListenableBuilder<double>(
  valueListenable: _h5pController.downloadProgress,
  builder: (_, value, __) {
    if (value > 0 && value < 1) {
      return LinearProgressIndicator(value: value);
    }

    return Expanded(child: webView);
  },
);
```
