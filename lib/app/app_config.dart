const String kDefaultApiBaseUrl = 'https://aub.owlsolutions.net/api/v1';

class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const raw = String.fromEnvironment(
      'AUB_API_BASE_URL',
      defaultValue: kDefaultApiBaseUrl,
    );
    return AppConfig(apiBaseUrl: _normalizeBaseUrl(raw));
  }

  final String apiBaseUrl;

  bool get usesHttps => apiBaseUrl.toLowerCase().startsWith('https://');

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
