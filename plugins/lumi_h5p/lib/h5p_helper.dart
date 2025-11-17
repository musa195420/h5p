class H5PUrlHelper {
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
