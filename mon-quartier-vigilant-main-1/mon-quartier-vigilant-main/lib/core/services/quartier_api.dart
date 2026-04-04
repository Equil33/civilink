import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/commune_model.dart';
import '../models/quartier_model.dart';

class QuartierApi {
  static const List<String> _fallbackQuartierNames = [
    'Baguida',
    'Kpogan',
    'Bè-Est',
    'Tokoin Wuiti',
    'Tokoin Tamé',
    'Tokoin Enyonam',
    'Hédzranawoé (1 et 2)',
    'Tokoin Aviation',
    'Kégué',
    'Atiégouvi',
    'Tokoin Elavagnon',
    'Gbonvié',
    'Doumasséssé (Adewi)',
    'Cité OUA',
    'Lomé II',
    'Kélégouvi',
    'Hanoukopé',
    'Dékon',
    'Bassadji',
    "N'tifafa-komé",
    'Aguiakomé',
    'Assivito',
    'Kodjoviakopé',
    'Adidogomé',
    'Sagbado',
    'Togblekopé',
    'Agoè-nyivé',
    'Agbalépédogan',
    'Attikoumè',
    'Avédji',
    'Sanguéra',
    'Klikamé',
    'Kohé',
    'Togblékopé',
    'Zossimé',
    'Dékpor',
    'Afiadényigban',
    'Adétikopé',
    'Vakpossito',
    'Légbassito',
  ];

  static List<Quartier> get fallbackQuartiers => List<Quartier>.generate(
        _fallbackQuartierNames.length,
        (index) => Quartier(
          id: index + 1,
          name: _fallbackQuartierNames[index],
          communeId: 1,
        ),
        growable: false,
      );

  static const String _rawBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _apiPrefix = '/api/civilink';
  static const String _localDevBaseUrl = 'http://127.0.0.1:8080';

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

  Future<List<Quartier>> fetchQuartiers({bool fallbackOnError = true}) async {
    try {
      final response = await http.get(_uri('/quartiers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Quartier.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      if (fallbackOnError) return fallbackQuartiers;
      throw Exception('Failed to load quartiers (${response.statusCode})');
    } catch (_) {
      if (fallbackOnError) return fallbackQuartiers;
      rethrow;
    }
  }

  Future<List<Commune>> fetchCommunes() async {
    final response = await http.get(_uri('/communes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Commune.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load communes (${response.statusCode})');
    }
  }
}
