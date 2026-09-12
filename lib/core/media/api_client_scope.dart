import 'package:flutter/material.dart';
import 'package:aub/core/api/api_client.dart';

class ApiClientScope extends InheritedWidget {
  const ApiClientScope({
    super.key,
    required this.client,
    required super.child,
  });

  final ApiClient client;

  static ApiClient? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiClientScope>()?.client;
  }

  @override
  bool updateShouldNotify(ApiClientScope oldWidget) => client != oldWidget.client;
}
