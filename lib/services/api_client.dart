import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  final int statusCode;
  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

class ApiClient {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  String get baseUrl {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return _configuredBaseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    }
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
    Map<String, String?> query = const {},
  }) {
    return _send('GET', path, token: token, query: query);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) {
    return _send('POST', path, token: token, body: body);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) {
    return _send('PUT', path, token: token, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    String? token,
    Map<String, String?> query = const {},
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, _uri(path, query));
    request.headers.addAll(_headers(token));
    if (body != null) request.body = jsonEncode(body);

    final streamed = await request.send();
    final resolved = await http.Response.fromStream(streamed);
    return _decode(resolved);
  }

  Uri _uri(String path, Map<String, String?> query) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final params = {
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    return Uri.parse('$baseUrl/')
        .resolve(cleanPath)
        .replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.trim();
    final decoded = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);
    final json = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{'data': decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    final error = json['error'];
    if (error is Map) {
      throw ApiException(
        statusCode: response.statusCode,
        code: error['code']?.toString() ?? 'HTTP_ERROR',
        message: error['message']?.toString() ?? 'Error del servidor',
        details: error['details'],
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_ERROR',
      message: 'Error del servidor',
      details: json,
    );
  }
}
