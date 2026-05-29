import 'dart:convert';

import 'package:http/http.dart' as http;

import 'storage_service.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _client.get(_uri(path), headers: _headers());
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final response = await _client.delete(_uri(path), headers: _headers());
    return _decode(response);
  }

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    try {
      // Import storage_service dynamically or use it if imported
      final code = StorageService.to.savedCode;
      if (code != null) {
        headers['X-User-Code'] = code;
      }
    } catch (_) {}
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final error = decoded['error'];
    if (error is Map && error['message'] != null) {
      throw Exception(error['message']);
    }
    throw Exception('HTTP ${response.statusCode}');
  }
}
