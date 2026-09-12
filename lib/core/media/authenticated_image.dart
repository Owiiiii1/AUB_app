import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/media/api_client_scope.dart';
import 'package:aub/core/media/authenticated_media_url.dart';

class AuthenticatedImage extends StatefulWidget {
  const AuthenticatedImage({
    super.key,
    required this.url,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  final String url;
  final Widget placeholder;
  final BoxFit fit;

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  static final Map<String, Uint8List> _memory = {};

  Uint8List? _bytes;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = null;
      _failed = false;
      _resolve();
    }
  }

  void _resolve() {
    if (!isAuthenticatedMediaUrl(widget.url)) {
      _failed = true;
      return;
    }
    final cached = _memory[widget.url];
    if (cached != null) {
      _bytes = cached;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    final client = ApiClientScope.maybeOf(context);
    if (client == null) {
      setState(() => _failed = true);
      return;
    }
    try {
      final bytes = await client.getBytes(widget.url);
      _memory[widget.url] = bytes;
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _failed = false;
        });
      }
    } on ApiException {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (_failed || bytes == null) {
      return widget.placeholder;
    }
    return Image.memory(
      bytes,
      fit: widget.fit,
      gaplessPlayback: true,
    );
  }
}
