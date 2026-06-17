class PhotoUrlHelper {
  static final _ipPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');

  static String ensureProtocol(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (_ipPattern.hasMatch(url)) return 'http://$url';
    return url;
  }

  static bool isRemoteUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://') || _ipPattern.hasMatch(url);
  }
}
