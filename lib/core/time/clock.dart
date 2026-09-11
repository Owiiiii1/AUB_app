class AcademyClock {
  const AcademyClock({DateTime Function()? now}) : _now = now;

  final DateTime Function()? _now;

  DateTime now() => _now?.call() ?? DateTime.now();
}
