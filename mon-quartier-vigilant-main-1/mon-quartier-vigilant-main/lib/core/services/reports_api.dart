import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/report_model.dart';

class ReportsApi {
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

  String resolveMediaUrl(String path) {
    if (path.isEmpty) return path;
    final normalized = path.trim();
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    final rawBase = _rawOrDefaultBaseUrl;
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final hostBase = base.endsWith(_apiPrefix)
        ? base.substring(0, base.length - _apiPrefix.length)
        : base;
    if (normalized.startsWith('/')) {
      return '$hostBase$normalized';
    }
    return '$hostBase/$normalized';
  }

  String _errorMessage(http.Response res, String fallback) {
    try {
      if (res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic> && decoded['error'] != null) {
          return decoded['error'].toString();
        }
      }
    } catch (_) {}
    if (res.body.isEmpty) return '$fallback (${res.statusCode})';
    // Avoid flooding the UI: keep a short excerpt of the raw body for debugging.
    final raw = res.body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final excerpt = raw.length <= 240 ? raw : '${raw.substring(0, 240)}...';
    return '$fallback (${res.statusCode}): $excerpt';
  }

  Map<String, String> _headers({String? accessToken}) {
    if (accessToken == null || accessToken.isEmpty) return {};
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<List<ReportModel>> fetchReports({String? accessToken}) async {
    final res = await http.get(
      _uri('/reports'),
      headers: _headers(accessToken: accessToken),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('GET /reports failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as List<dynamic>;
    return body
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReportModel>> fetchMyReports({required String accessToken}) async {
    final res = await http.get(
      _uri('/reports/mine'),
      headers: _headers(accessToken: accessToken),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(_errorMessage(res, 'GET /reports/mine failed'));
    }

    final body = jsonDecode(res.body) as List<dynamic>;
    return body
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReportModel> createReport({
    required String title,
    required String description,
    required String category,
    required String quartier,
    required int quartierId,
    required String address,
    required String reporterId,
    required String reporterType,
    double? latitude,
    double? longitude,
    List<String> nearbyOrganisations = const [],
    String? accessToken,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      ..._headers(accessToken: accessToken),
    };
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'quartier': quartier,
      // Some backends expect camelCase, others snake_case.
      'quartierId': quartierId,
      'quartier_id': quartierId,
      'address': address,
      ...?(latitude == null ? null : {'latitude': latitude}),
      ...?(longitude == null ? null : {'longitude': longitude}),
      'nearbyOrganisations': nearbyOrganisations,
      'reporterId': reporterId,
      'reporterType': reporterType,
    };
    final res = await http.post(
      _uri('/reports'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(_errorMessage(res, 'POST /reports failed'));
    }

    return ReportModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> updateStatus(String id, String status, {String? accessToken}) async {
    final headers = {
      'Content-Type': 'application/json',
      ..._headers(accessToken: accessToken),
    };
    final res = await http.patch(
      _uri('/reports/$id/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('PATCH /reports/:id/status failed (${res.statusCode})');
    }
  }

  Future<void> incrementVote(String id, {String? accessToken}) async {
    final headers = {
      'Content-Type': 'application/json',
      ..._headers(accessToken: accessToken),
    };
    final res = await http.patch(
      _uri('/reports/$id/vote'),
      headers: headers,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('PATCH /reports/:id/vote failed (${res.statusCode})');
    }
  }

  Future<ReportModel> updateReport({
    required String id,
    required String title,
    required String description,
    required String category,
    required String quartier,
    required String address,
    double? latitude,
    double? longitude,
    List<String> nearbyOrganisations = const [],
    required String accessToken,
  }) async {
    final res = await http.patch(
      _uri('/reports/$id'),
      headers: {
        'Content-Type': 'application/json',
        ..._headers(accessToken: accessToken),
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'quartier': quartier,
        'address': address,
        ...?(latitude == null ? null : {'latitude': latitude}),
        ...?(longitude == null ? null : {'longitude': longitude}),
        'nearbyOrganisations': nearbyOrganisations,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(_errorMessage(res, 'PATCH /reports/:id failed'));
    }

    return ReportModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteReport({
    required String id,
    required String accessToken,
  }) async {
    final res = await http.delete(
      _uri('/reports/$id'),
      headers: _headers(accessToken: accessToken),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(_errorMessage(res, 'DELETE /reports/:id failed'));
    }
  }
}
