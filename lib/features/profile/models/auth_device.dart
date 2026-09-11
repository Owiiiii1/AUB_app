class AuthDevice {
  const AuthDevice({
    required this.id,
    required this.name,
    required this.current,
    this.lastUsedAt,
    this.createdAt,
  });

  final int id;
  final String name;
  final bool current;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  factory AuthDevice.fromJson(Map<String, dynamic> json) {
    return AuthDevice(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      current: json['current'] == true,
      lastUsedAt: _parseTime(json['last_used_at']),
      createdAt: _parseTime(json['created_at']),
    );
  }

  static DateTime? _parseTime(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
