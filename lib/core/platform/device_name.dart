import 'package:flutter/foundation.dart';

String defaultDeviceName() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'AUB Android',
    TargetPlatform.iOS => 'AUB iOS',
    TargetPlatform.windows => 'AUB Windows',
    TargetPlatform.macOS => 'AUB macOS',
    TargetPlatform.linux => 'AUB Linux',
    TargetPlatform.fuchsia => 'AUB App',
  };
}
