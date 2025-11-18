# 🎯 Lumi_H5P

A new **Flutter package** that helps you **play Lumi H5P files locally** — no external H5P server required! 🚀

Bring interactive H5P learning experiences directly into your Flutter apps — **offline, serverless, and simple**.

---

## 📱 About

**lumi_h5p** enables developers and educators to **load, download, and play H5P interactive content** directly on mobile devices.  
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

## For Improvements And Suggestions Raise Issue

https://github.com/musa195420/h5p/issues

**Github Link**
https://github.com/musa195420/h5p/tree/auto

**Connect With Me Through**
https://muhammad-musa.netlify.app/

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

H5pWebView webView = H5pWebView(
      controller: _h5pcontroller,
      listenToEvents:
          true, //only needed if you want to listen to events like marks and anything else
      onXApiEvent: (event) {
       h5pLog(message:📢 xAPI Event: $event);
      },
    );

   ValueListenableBuilder<H5PLoadStatus>(
            valueListenable: _h5pcontroller.status,
            builder: (_, status, __) {
              if (status == H5PLoadStatus.downloading) {
                return Column(
                  children: [
                    const Text("Downloading..."),
                    ValueListenableBuilder<double>(
                      valueListenable: _h5pcontroller.downloadProgress,
                      builder: (_, progress, __) =>
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
                      builder: (_, progress, __) => LinearProgressIndicator(
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


<!-- ✅ Under Application Tag -->
<application
    android:name="${applicationName}"
    android:label="test_h5p"
    android:usesCleartextTraffic="true" <!-- Allow local HTTP -->
android:networkSecurityConfig="@xml/network_security_config"<!-- Add Http Rules -->
    android:icon="@mipmap/ic_launcher">
```

🧩 (Optional) Add Internet Permission

Add this above the <application> tag:

```xml
<!-- ✅ Add required permissions here -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.DOWNLOAD_WITHOUT_NOTIFICATION"/>
```

**Add new Folder in (Project Root) Android>src>main>res**
Create folder Named xml and create file **network_security_config.xml** and paste following code in it

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>

    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">127.0.0.1</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
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

## v1.0.6 – Initial Release

Watch a quick demo showing how `Lumi_H5P` works in action:

## 💡 Usage Example Gif

Watch the demo directly in the README:

Here are some screenshots of Lumi_H5P in action:

<div>
   <img src="https://camo.githubusercontent.com/692d52dc69e3c91fece8aad35881b2d34c50186bc67a38d385c8f0b39da485a9/68747470733a2f2f64726976652e676f6f676c652e636f6d2f75633f6578706f72743d766965772669643d3178487a694b5865634b34474733664338794c6b6878344733385f76486c63682d" alt="Lumi_H5P Demo" width="200"/>
  <img src="https://camo.githubusercontent.com/2810c19434106b75179fb3b706aed6bc7888856fbddc7372453f98cd5332161a/68747470733a2f2f64726976652e676f6f676c652e636f6d2f75633f6578706f72743d766965772669643d315f45424f746c71644c6364362d31554d54525a59535f69384c2d59764a735477" alt="Example 1" width="200" style="margin-right:5px"/>
  <img src="https://camo.githubusercontent.com/203e334d793db3cee3a8b13cfbe7d03d6fa2ee2fe84bb64e3d13b30957c2de5d/68747470733a2f2f64726976652e676f6f676c652e636f6d2f75633f6578706f72743d766965772669643d3162344432764a696c2d366164546c555a562d33627a4468584c78397253556171" alt="Example 2" width="200" style="margin-right:5px"/>
 </div>
<div>
  
  <img src="https://camo.githubusercontent.com/81b64de708f9e83cd834ed8cace2ede17aed2078a3f90d228953894283835922/68747470733a2f2f64726976652e676f6f676c652e636f6d2f75633f6578706f72743d766965772669643d3131476b7430306146496f6d3758326953336b5779612d713048333076794a7053" alt="Example 3" width="120"/>
  <img src="https://camo.githubusercontent.com/1dfe17f125da2825ac76eb5d1d79e9b25ef3d1c765c33f491f530b5c4e077941/68747470733a2f2f64726976652e676f6f676c652e636f6d2f75633f6578706f72743d766965772669643d314a4a4678474e666131654c45366457614e4f7a75495171376e7a2d62676a3667" alt="Example 4" width="400"/>
</div>

## 🎬 Usage Example Video

[Watch Demo Video](https://drive.google.com/file/d/1W36PnIwCx2rGX0iDNJvalznizEcWDUTt/view) 🎬

Made with ❤️ by the community for educators, learners, and Flutter developers.

```

```
