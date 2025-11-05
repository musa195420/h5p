✅ Clear overview and features
✅ Usage example
✅ Complete iOS & Android configuration
✅ Installation steps
✅ Contribution and roadmap sections
✅ Polished formatting with emojis and syntax-highlighted code blocks

# 🎯 test_h5p

A new **Flutter package** that helps you **play Lumi H5P files locally** — no external H5P server required! 🚀

Bring interactive H5P learning experiences directly into your Flutter apps — **offline, serverless, and simple**.

---

## 📱 About

**test_h5p** enables developers and educators to **load, download, and play H5P interactive content** directly on mobile devices.  
It’s especially useful for **offline schooling or e-learning environments**, where access to an H5P server is limited or unavailable.

---

## ✨ Features

✅ Play `.h5p` files **locally** — no internet needed after download  
✅ **No H5P server** or backend rendering required  
✅ Automatically downloads `.h5p` files from a direct URL  
✅ Perfect for **educational and e-learning** use cases  
✅ Planned updates:

- 🔄 Background downloads using `HashMap<String, String>`
- 💾 Caching & offline playback
- 🧩 Improved rendering and user interface

---

## 🧩 How It Works

1. **Upload** your `.h5p` file to **Lumi** or another accessible online location.
2. **Copy the direct URL** of your `.h5p` file.
3. **Provide the URL** to this package’s controller.
4. The package will:
   - 📦 Download the file
   - 🧠 Unpack and render it locally
   - 🎮 Play it seamlessly inside your app

No server, no hassle — everything happens **locally**. 🌐❌

---

## 🆓 License & Usage

This package is **free to use** for **schooling and educational purposes**. 🏫  
Commercial usage is allowed with attribution. Future versions will include additional offline and background features.

---

## 🚀 Getting Started

Add this package to your `pubspec.yaml` file:

## Yaml

dependencies:
test_h5p: ^0.1.0

**Then, install it:**

**flutter pub get**

_Finally, import it in your Dart file_

**import 'package:test_h5p/test_h5p.dart';**

💡 Example Usage

Here’s a simple example showing how to play an H5P file:

## Dart

```dart
import 'package:test_h5p/test_h5p.dart';

LumiH5PController _h5pController = LumiH5PController();

H5pWebView webView = H5pWebView(controller: _h5pController);

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

# 🍎 iOS Configuration

If you’re targeting iOS, you need to allow local networking so the app can load H5P files from local storage or localhost.

📂 File Location
ios/Runner/Info.plist

🧩 Add the Following Inside the <dict> Tag

(but not inside any other <dict>)

```plist
<key>NSAppTransportSecurity</key>
<dict>
  <!-- Allow local HTTP (127.0.0.1, localhost) -->
  <key>NSAllowsLocalNetworking</key>
  <true/>

  <!-- General rule for HTTP (optional if you only use localhost) -->
  <key>NSAllowsArbitraryLoads</key>
  <true/>

  <!-- (Optional) Restrict to localhost only -->
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSIncludesSubdomains</key>
      <true/>
    </dict>
    <key>127.0.0.1</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSIncludesSubdomains</key>
      <true/>
    </dict>
  </dict>
</dict>
```

##✅ After Updating

Run:

flutter clean
flutter pub get
flutter run

## 🤖 Android Configuration

**For Android, ensure that your app can access local files and HTTP connections.**

**📂 File Location**
_android/app/src/main/AndroidManifest.xml_

## 🧩 Add the Following Inside the <application> Tag

```xml

<application
    android:name="${applicationName}"
    android:label="test_h5p"
    android:usesCleartextTraffic="true" <!-- Allow local HTTP -->
    android:icon="@mipmap/ic_launcher">
```

🧩 (Optional) Add Internet Permission

Add this above the <application> tag:

```
<uses-permission android:name="android.permission.INTERNET"/>
```

**This allows the package to fetch .h5p files from remote URLs before caching them locally.**

## 🧠 Why These Settings Are Needed

By default, both iOS and Android restrict local HTTP access for security reasons.
Because this package plays .h5p files locally (via WebView and internal file loading), these permissions are required to ensure:

🔓 Local network access

📂 Smooth local file rendering

⚙️ Compatibility across all Flutter platforms

🧭 Future Roadmap

Background download of multiple H5P files

Offline caching using HashMap<String, String>

Improved H5P player user interface

Android and iOS native performance optimizations

Example app with interactive demos

💬 Contribute

We welcome contributions from the community! 🤝

Feel free to:

🪲 Report bugs

💡 Suggest features

🧑‍💻 Submit pull requests

Together, let’s make H5P local playback simple, open-source, and reliable. 💪

🏷️ Version

## v0.1.0 – Initial Release

Made with ❤️ by the community for educators, learners, and Flutter developers.

```

```
