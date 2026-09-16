bool isValidUrl(String value) {
  if (value.isEmpty || value.trim() != value || RegExp(r'\s').hasMatch(value)) {
    return false;
  }

  final uri = Uri.tryParse(value);
  if (uri == null ||
      (uri.scheme != "http" && uri.scheme != "https") ||
      uri.host.isEmpty ||
      !uri.host.contains(".") ||
      uri.host.startsWith(".") ||
      uri.host.endsWith(".") ||
      uri.host.contains("..")) {
    return false;
  }

  return true;
}
