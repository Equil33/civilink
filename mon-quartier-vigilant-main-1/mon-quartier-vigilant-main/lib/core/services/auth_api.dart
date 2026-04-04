import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AuthApi {
  static const String _rawBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _apiPrefix = '/api/civilink';
  static const String _localDevBaseUrl = 'http://127.0.0.1:8080';

  bool get enabled => _rawBaseUrl.trim().isNotEmpty || kIsWeb;

  String get _rawOrDefaultBaseUrl {
    final raw = _rawBaseUrl.trim();
    if (raw.isNotEmpty) return raw;
    if (kIsWeb) return Uri.base.origin;
    return _localDevBaseUrl;
  }

  String get _baseUrl {
    final base = _rawOrDefaultBaseUrl;
    final noTrailingSlash =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    if (noTrailingSlash.endsWith(_apiPrefix)) return noTrailingSlash;
    return '$noTrailingSlash$_apiPrefix';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> registerCitizen({
    required String nom,
    required String prenoms,
    required String idType,
    required String idNumber,
    required String idExpirationDate,
    required String phone,
    required String email,
    required String password,
    required String quartier,
  }) async {
    return _post(
      '/auth/register/citoyen',
      {
        'nom': nom,
        'prenoms': prenoms,
        'idType': idType,
        'idNumber': idNumber,
        'idExpirationDate': idExpirationDate,
        'phone': phone,
        'email': email,
        'password': password,
        'quartier': quartier,
      },
    );
  }

  Future<Map<String, dynamic>> registerOrganisation({
    required String orgType,
    required String orgName,
    required String orgResponsible,
    required String serviceCardNumber,
    required String phone,
    required String email,
    required String password,
    required String commune,
  }) async {
    return _post(
      '/auth/register/organisation',
      {
        'orgType': orgType,
        'orgName': orgName,
        'orgResponsible': orgResponsible,
        'serviceCardNumber': serviceCardNumber,
        'phone': phone,
        'email': email,
        'password': password,
        'commune': commune,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
    String? orgType,
  }) async {
    return _post(
      '/auth/login',
      {
        'email': email,
        'password': password,
        'role': role,
        if (orgType != null && orgType.isNotEmpty) 'orgType': orgType,
      },
    );
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final res = await http.post(
      _uri('/auth/token/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );
    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = res.body;
      }
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = body is Map<String, dynamic>
          ? (body['detail'] ?? body['error'] ?? body['message'])
          : body;
      throw StateError(message?.toString() ?? 'Token refresh failed (${res.statusCode})');
    }
    if (body is Map<String, dynamic>) return body;
    throw StateError('Token refresh failed: invalid JSON response');
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final res = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = res.body;
      }
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = body is Map<String, dynamic>
          ? (body['error'] ?? body['detail'] ?? body['message'])
          : body;
      throw StateError(message?.toString() ?? 'Request failed (${res.statusCode})');
    }
    if (body is Map<String, dynamic>) return body;
    throw StateError('Request failed: invalid JSON response');
  }
}
