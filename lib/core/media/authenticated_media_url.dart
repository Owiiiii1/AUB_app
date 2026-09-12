bool isAuthenticatedMediaUrl(String? value) {
  if (value == null || value.isEmpty) {
    return false;
  }
  return value.contains('/api/v1/files/');
}
