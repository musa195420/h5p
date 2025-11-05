class H5PUrlHelper {
  /// Normalize any user-provided URL input into a Map<String, String>
  /// - If user provides a map, it’s returned as-is.
  /// - If user provides a list, it’s converted into numbered keys.
  /// - If both are null, it returns an empty map.
  static Map<String, String> normalize({
    List<String>? urls,
    Map<String, String>? urlMap,
  }) {
    if (urlMap != null && urlMap.isNotEmpty) {
      return urlMap;
    }

    if (urls != null && urls.isNotEmpty) {
      return {
        for (int i = 0; i < urls.length; i++) 'H5P ${i + 1}': urls[i],
      };
    }

    return {};
  }
}
