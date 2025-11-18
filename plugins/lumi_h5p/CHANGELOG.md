# 📜 Changelog

All notable changes to this project will be documented in this file.

---

## [1.1.0] - 2025-11-18

### 🚀 Added

- **Offline support for H5P content**:
  - H5P files are now downloaded, extracted, and cached locally.
  - Files can be loaded from local storage if already downloaded, reducing repeated downloads.
  - Added optional `refName` parameter in `loadH5P` to load content using a reference name instead of URL.
  
- **Download & extraction progress indicators**:
  - Live **download progress** using `ValueListenableBuilder<double>` linked to `_h5pcontroller.downloadProgress`.
  - Live **extraction progress** using `_h5pcontroller.extractProgress`.
  - Visual feedback in UI with `LinearProgressIndicator`.

- **Request management improvements**:
  - Ability to **add multiple H5P requests** at once via `addRequestList`.
  - Select and remove individual requests or clear all requests from the controller.
  - `H5PLoadStatus` enum now includes `downloading`, `extracting`, `downloaded`, `failed` for detailed status handling.
  
- **Horizontal scrollable H5P buttons**:
  - Users can select content for immediate load or load without a ref name.
  - Enhanced UI with better spacing, border, and rounded corners for request buttons.

- **Event listener for H5P xAPI events**:
  - Hook added to log xAPI events emitted by the H5P content via `onXApiEvent`.

### 🧩 Improved

- Optimized **request and selection handling**:
  - `Set<H5PRequestModel>` used for selection to avoid duplicates.
  - Added checkbox selection for batch removal.
  
- **UI improvements**:
  - Requests list with live status icons (`Icons.check_circle`, `Icons.downloading`, `Icons.error`, etc.).
  - Cleaner layout with `SingleChildScrollView` for horizontal H5P selection buttons.
  - Better separation between loader, webview, and request list sections.

- **Controller optimizations**:
  - `_h5pcontroller` now handles all lifecycle events: download, extract, serve, and load.
  - Added safe null handling and progress fallback for extraction (`progress > 0 ? progress : null`).

### 🧰 Internal

- Refactored old **single-download method** to full **H5P lifecycle management**.
- `H5PRequestModel` now supports `priority` for download order.
- Updated example app (`TestView`) to reflect full functionality with offline and online H5P loading.
- Debug and error logging flags (`h5pDebug`, `h5pError`) added for better development experience.

---

✅ **Summary**:  
The key improvement here is **offline support** with caching, multi-request management, live download/extraction progress, and improved UI. The old version only had a single method to download H5P files without offline reuse or progress tracking.
