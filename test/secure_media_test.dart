import 'dart:async';
import 'dart:typed_data';

import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/media/api_client_scope.dart';
import 'package:aub/core/media/authenticated_media_url.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _fileUrl =
    'https://aub.owlsolutions.net/api/v1/files/11111111-1111-1111-1111-111111111111';

void main() {
  test('secure media URLs are recognized without treating public storage as safe', () {
    expect(isAuthenticatedMediaUrl(_fileUrl), isTrue);
    expect(isAuthenticatedMediaUrl('/api/v1/files/abc'), isTrue);
    expect(
      isAuthenticatedMediaUrl('https://aub.owlsolutions.net/storage/students/1.jpg'),
      isFalse,
    );
    expect(isAuthenticatedMediaUrl(null), isFalse);
  });

  test('getBytes sends bearer header and never puts the token in the URL', () async {
    RequestOptions? captured;
    final dio = Dio(BaseOptions(baseUrl: 'https://aub.owlsolutions.net/api/v1'));
    dio.httpClientAdapter = _CallbackAdapter((options) {
      captured = options;
      return ResponseBody.fromBytes(
        _tinyJpeg,
        200,
        headers: {
          Headers.contentTypeHeader: ['image/jpeg'],
        },
      );
    });
    final client = ApiClient(
      config: const AppConfig(apiBaseUrl: 'https://aub.owlsolutions.net/api/v1'),
      dio: dio,
    );
    client.setAccessToken('secret-token');

    final bytes = await client.getBytes(_fileUrl);

    expect(bytes, isNotEmpty);
    expect(captured, isNotNull);
    expect(captured!.path, 'files/11111111-1111-1111-1111-111111111111');
    expect(captured!.uri.query, isEmpty);
    expect(captured!.uri.toString().contains('secret-token'), isFalse);
    expect(captured!.headers['Authorization'], 'Bearer secret-token');
  });

  test('401 from file fetch invokes global unauthorized handler', () async {
    var called = false;
    final dio = Dio(BaseOptions(baseUrl: 'https://aub.owlsolutions.net/api/v1'));
    dio.httpClientAdapter = _CallbackAdapter((options) {
      return ResponseBody.fromString(
        '{"success":false,"error":{"code":"unauthenticated","message":"Unauthenticated."}}',
        401,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
    final client = ApiClient(
      config: const AppConfig(apiBaseUrl: 'https://aub.owlsolutions.net/api/v1'),
      dio: dio,
      onUnauthorized: () => called = true,
    );
    client.setAccessToken('expired');

    await expectLater(
      client.getBytes(_fileUrl),
      throwsA(isA<ApiException>().having((e) => e.isUnauthorized, 'unauthorized', isTrue)),
    );
    expect(called, isTrue);
  });

  testWidgets('missing photo shows initials', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AubAvatar(size: 48, name: 'Mario Rossi'),
        ),
      ),
    );
    expect(find.text('MR'), findsOneWidget);
  });

  testWidgets('forbidden or missing file shows initials placeholder', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://aub.owlsolutions.net/api/v1'));
    dio.httpClientAdapter = _CallbackAdapter((options) {
      return ResponseBody.fromString(
        '{"success":false,"error":{"code":"not_found","message":"Not found."}}',
        404,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
    final client = ApiClient(
      config: const AppConfig(apiBaseUrl: 'https://aub.owlsolutions.net/api/v1'),
      dio: dio,
    );
    client.setAccessToken('token');

    await tester.pumpWidget(
      ApiClientScope(
        client: client,
        child: const MaterialApp(
          home: Scaffold(
            body: AubAvatar(
              size: 48,
              name: 'Mario Rossi',
              photoUrl: _fileUrl,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('MR'), findsOneWidget);
  });
}

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.onFetch);

  final ResponseBody Function(RequestOptions options) onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onFetch(options);
  }
}

const _tinyJpeg = <int>[
  0xFF, 0xD8, 0xFF, 0xD9,
];
