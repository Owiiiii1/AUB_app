bool isSafeHttpsUrl(String? value) {
  if (value == null || value.isEmpty) {
    return false;
  }
  final uri = Uri.tryParse(value);
  return uri != null && uri.isAbsolute && uri.scheme == 'https';
}
