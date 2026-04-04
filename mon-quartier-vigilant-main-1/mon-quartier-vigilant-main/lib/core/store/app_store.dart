import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/commune_model.dart';
import '../models/quartier_model.dart';
import '../models/report_model.dart';
import '../services/auth_api.dart';
import '../services/quartier_api.dart';
import '../services/reports_api.dart';

class AppStore extends ChangeNotifier {
  static const _reportsKey = 'mqv_reports';
  static const _sessionKey = 'mqv_session';
  static const _guestProfileKey = 'mqv_guest_profile';
  static const _bannedGuestIdsKey = 'mqv_banned_guest_ids';
  static const _languageKey = 'mqv_language';
  static const _themeKey = 'mqv_theme';
  static const _seenResolutionPhotosKey = 'mqv_seen_resolution_photos';
  static const int quickReportLimit = 3;

  final List<ReportModel> _reports = [];
  final Set<String> _bannedGuestIds = {};
  final Set<String> _seenResolutionPhotos = {};
  final ReportsApi _reportsApi = ReportsApi();
  final AuthApi _authApi = AuthApi();
  final QuartierApi _quartierApi = QuartierApi();
  final List<Quartier> _quartiers = [];
  final List<Commune> _communes = [];
  String role = 'guest';
  String userName = 'Invite';
  String userId = '';
  String accessToken = '';
  String refreshToken = '';
  Map<String, String> _citizenProfile = {};
  String guestReporterId = '';
  int quickReportsUsed = 0;
  String _language = 'fr';
  String _themeMode = 'system';
  final int _totalUsers = 0;

  bool get isGuest => role == 'guest';
  bool get isCitizen => role == 'citoyen';
  bool get isOrganisation => role == 'organisation';
  bool get isMember => !isGuest;
  Map<String, String> get citizenProfile => Map.unmodifiable(_citizenProfile);
  bool get hasCitizenProfile => _citizenProfile.isNotEmpty;
  bool get isGuestReporterBanned => _bannedGuestIds.contains(guestReporterId);
  String get language => _language;
  String get themeMode => _themeMode;
  int get totalUsers => _totalUsers;
  int get quickReportsRemaining {
    final remaining = quickReportLimit - quickReportsUsed;
    return remaining < 0 ? 0 : remaining;
  }

  List<Quartier> get quartiers => List.unmodifiable(_quartiers);
  List<Commune> get communes => List.unmodifiable(_communes);

  String get maskedGuestReporterId {
    if (guestReporterId.length < 6) return guestReporterId;
    final start = guestReporterId.substring(0, 4);
    final end = guestReporterId.substring(guestReporterId.length - 2);
    return '$start****$end';
  }

  List<ReportModel> get reportsForCurrentOrganisation {
    if (!isOrganisation) return [];
    return _reports.where((r) => r.nearbyOrganisations.contains(userName)).toList();
  }

  List<ReportModel> get reports => List.unmodifiable(_reports);

  int get total => _reports.length;

  int get newCount => _reports.where((r) => r.status == 'nouveau').length;

  int get inProgressCount => _reports.where((r) => r.status == 'en_cours').length;

  int get resolvedCount => _reports.where((r) => r.status == 'resolu').length;
  int get unseenResolutionPhotoCount {
    var count = 0;
    for (final report in _reports) {
      for (final url in report.resolutionPhotos) {
        if (!_seenResolutionPhotos.contains(url)) {
          count += 1;
        }
      }
    }
    return count;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_sessionKey);
    if (rawSession != null) {
      final session = jsonDecode(rawSession) as Map<String, dynamic>;
      userName = session['name'] as String? ?? 'Invite';
      role = session['role'] as String? ?? 'guest';
      userId = session['userId']?.toString() ?? '';
      accessToken = session['accessToken'] as String? ?? '';
      refreshToken = session['refreshToken'] as String? ?? '';
      _citizenProfile = _decodeProfile(session['citizenProfile']);
      if (userId.isEmpty && accessToken.isNotEmpty) {
        userId = _extractUserIdFromAccessToken(accessToken);
      }
    }

    _language = prefs.getString(_languageKey) ?? 'fr';
    _themeMode = prefs.getString(_themeKey) ?? 'system';
    final seen = prefs.getStringList(_seenResolutionPhotosKey);
    if (seen != null) {
      _seenResolutionPhotos.addAll(seen);
    }

    if (_reportsApi.enabled) {
      try {
        final fromApi = isCitizen && accessToken.isNotEmpty
            ? await _reportsApi.fetchMyReports(accessToken: accessToken)
            : await _reportsApi.fetchReports(accessToken: accessToken);
        _reports
          ..clear()
          ..addAll(fromApi);
      } catch (_) {
        _reports.addAll(_seed());
      }
    } else {
      final rawReports = prefs.getString(_reportsKey);
      if (rawReports == null) {
        _reports.addAll(_seed());
        await _saveReports();
      } else {
        final list = jsonDecode(rawReports) as List<dynamic>;
        _reports.addAll(
          list.map((e) => ReportModel.fromJson(e as Map<String, dynamic>)),
        );
      }
    }
    // Prefer backend-provided quartiers so quartierId matches server DB.
    // Falls back to a local list if the API is unavailable.
    try {
      final fromApi = await _quartierApi.fetchQuartiers();
      _quartiers
        ..clear()
        ..addAll(fromApi);
    } catch (_) {
      _quartiers
        ..clear()
        ..addAll(
          List<Quartier>.generate(
            quartierNames.length,
            (i) => Quartier(id: i + 1, name: quartierNames[i], communeId: 1),
            growable: false,
          ),
        );
    }

    _reports.removeWhere((report) => !_quartiers.any((q) => q.name == report.quartier));

    final rawGuestProfile = prefs.getString(_guestProfileKey);
    if (rawGuestProfile != null) {
      final profile = jsonDecode(rawGuestProfile) as Map<String, dynamic>;
      guestReporterId =
          profile['guestReporterId'] as String? ?? _generateGuestReporterId();
      quickReportsUsed = profile['quickReportsUsed'] as int? ?? 0;
    } else {
      guestReporterId = _generateGuestReporterId();
      quickReportsUsed = 0;
      await _saveGuestProfile();
    }

    final banned = prefs.getStringList(_bannedGuestIdsKey);
    if (banned != null) {
      _bannedGuestIds.addAll(banned);
    }
  }

  String resolveMediaUrl(String path) => _reportsApi.resolveMediaUrl(path);

  bool hasUnseenResolutionPhotos(ReportModel report) {
    return report.resolutionPhotos.any((url) => !_seenResolutionPhotos.contains(url));
  }

  List<String> unseenResolutionPhotos(ReportModel report) {
    return report.resolutionPhotos.where((url) => !_seenResolutionPhotos.contains(url)).toList();
  }

  Future<void> markResolutionPhotosSeen(ReportModel report) async {
    if (report.resolutionPhotos.isEmpty) return;
    _seenResolutionPhotos.addAll(report.resolutionPhotos);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenResolutionPhotosKey, _seenResolutionPhotos.toList());
    notifyListeners();
  }

  Future<void> login(String name, String newRole) async {
    userName = name;
    role = newRole;
    userId = '';
    accessToken = '';
    refreshToken = '';
    _citizenProfile = {};
    await _saveSession();
    notifyListeners();
  }

  Future<void> logout() async {
    userName = 'Invite';
    role = 'guest';
    userId = '';
    accessToken = '';
    refreshToken = '';
    _citizenProfile = {};
    await _saveSession();
    notifyListeners();
  }

  Future<void> loginWithCredentials({
    required String email,
    required String password,
    required String role,
    String? orgType,
  }) async {
    if (_authApi.enabled) {
      final session = await _authApi.login(
        email: email,
        password: password,
        role: role,
        orgType: orgType,
      );
      userName = session['name'] as String? ?? 'Invite';
      this.role = session['role'] as String? ?? 'guest';
      userId = session['userId']?.toString() ?? '';
      accessToken = session['accessToken'] as String? ?? '';
      refreshToken = session['refreshToken'] as String? ?? '';
      _citizenProfile = _decodeProfile(session['citizenProfile']);
      if (_citizenProfile.isEmpty && this.role == 'citoyen') {
        _citizenProfile = {'email': email};
      }
      await _saveSession();
      notifyListeners();
      return;
    }

    await login(
      role == 'organisation' ? (orgType ?? 'Organisation') : 'Citoyen',
      role,
    );
  }

  Future<void> registerCitizen({
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
    if (_authApi.enabled) {
      final session = await _authApi.registerCitizen(
        nom: nom,
        prenoms: prenoms,
        idType: idType,
        idNumber: idNumber,
        idExpirationDate: idExpirationDate,
        phone: phone,
        email: email,
        password: password,
        quartier: quartier,
      );
      userName = session['name'] as String? ?? '$nom $prenoms';
      role = session['role'] as String? ?? 'citoyen';
      userId = session['userId']?.toString() ?? '';
      accessToken = session['accessToken'] as String? ?? '';
      refreshToken = session['refreshToken'] as String? ?? '';
      _citizenProfile = {
        'nom': nom,
        'prenoms': prenoms,
        'idType': idType,
        'idNumber': idNumber,
        'idExpirationDate': idExpirationDate,
        'phone': phone,
        'email': email,
        'quartier': quartier,
      };
      await _saveSession();
      notifyListeners();
      return;
    }

    await login('$nom $prenoms', 'citoyen');
    _citizenProfile = {
      'nom': nom,
      'prenoms': prenoms,
      'idType': idType,
      'idNumber': idNumber,
      'idExpirationDate': idExpirationDate,
      'phone': phone,
      'email': email,
      'quartier': quartier,
    };
    await _saveSession();
    notifyListeners();
  }

  Future<void> registerOrganisation({
    required String orgType,
    required String orgName,
    required String orgResponsible,
    required String serviceCardNumber,
    required String phone,
    required String email,
    required String password,
    required String commune,
  }) async {
    if (_authApi.enabled) {
      final session = await _authApi.registerOrganisation(
        orgType: orgType,
        orgName: orgName,
        orgResponsible: orgResponsible,
        serviceCardNumber: serviceCardNumber,
        phone: phone,
        email: email,
        password: password,
        commune: commune,
      );
      userName = session['name'] as String? ?? orgType;
      role = session['role'] as String? ?? 'organisation';
      userId = session['userId']?.toString() ?? '';
      accessToken = session['accessToken'] as String? ?? '';
      refreshToken = session['refreshToken'] as String? ?? '';
      await _saveSession();
      notifyListeners();
      return;
    }

    await login(orgType, 'organisation');
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'name': userName,
        'role': role,
        'userId': userId,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'citizenProfile': _citizenProfile,
      }),
    );
  }

  Future<void> addReport({
    required String title,
    required String description,
    required String category,
    required String quartier,
    required int quartierId,
    required String address,
    double? latitude,
    double? longitude,
    Uint8List? photoBytes,
    String? photoFilename,
    List<String>? nearbyOrganisations,
    bool isQuickReport = false,
  }) async {
    if (quartierId <= 0) {
      throw StateError('quartierId invalide.');
    }
    nearbyOrganisations ??= getNearbyOrganisations(quartier, category);
    if (_reportsApi.enabled && !isQuickReport && accessToken.isEmpty) {
      throw StateError('Authentification requise pour envoyer un signalement.');
    }

    var quickProfileUpdated = false;
    if (isQuickReport) {
      if (!canCreateQuickReport()) {
        throw StateError('Signalement rapide indisponible.');
      }
      quickReportsUsed += 1;
      await _saveGuestProfile();
      quickProfileUpdated = true;
    }

    try {
      final now = DateTime.now();
      if (_reportsApi.enabled) {
        final created = await _reportsApi.createReport(
          title: title,
          description: description,
          category: category,
          quartier: quartier,
          quartierId: quartierId,
          address: address,
          reporterId: isQuickReport
              ? guestReporterId
              : (userId.isNotEmpty ? userId : role),
          reporterType: isQuickReport ? 'quick_guest' : 'member',
          latitude: latitude,
          longitude: longitude,
          nearbyOrganisations: nearbyOrganisations,
          accessToken: accessToken,
        );
        var saved = created;
        if (photoBytes != null && photoBytes.isNotEmpty) {
          if (accessToken.isEmpty) {
            throw StateError("Connexion requise pour ajouter une photo.");
          }
          saved = await _reportsApi.uploadReportPhoto(
            id: created.id,
            bytes: photoBytes,
            filename: (photoFilename == null || photoFilename.isEmpty) ? 'photo.jpg' : photoFilename,
            accessToken: accessToken,
          );
        }
        _reports.insert(0, saved);
      } else {
        _reports.insert(
          0,
          ReportModel(
            id: now.microsecondsSinceEpoch.toString(),
            title: title,
            description: description,
            category: category,
            status: 'nouveau',
            quartier: quartier,
            address: address,
            latitude: latitude,
            longitude: longitude,
            nearbyOrganisations: nearbyOrganisations,
            photos: const [],
            date: '${now.day}/${now.month}/${now.year}',
            votes: 0,
            reporterId: isQuickReport
                ? guestReporterId
                : (userId.isNotEmpty ? userId : role),
            reporterType: isQuickReport ? 'quick_guest' : 'member',
            createdAt: now.toIso8601String(),
          ),
        );
        await _saveReports();
      }
      notifyListeners();
    } catch (_) {
      if (quickProfileUpdated && quickReportsUsed > 0) {
        quickReportsUsed -= 1;
        await _saveGuestProfile();
      }
      rethrow;
    }
  }

  bool canCreateQuickReport() {
    return !isGuestReporterBanned && quickReportsRemaining > 0;
  }

  bool isGuestReporterIdBanned(String reporterId) {
    return _bannedGuestIds.contains(reporterId);
  }

  Future<void> banGuestReporter(String reporterId) async {
    _bannedGuestIds.add(reporterId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bannedGuestIdsKey, _bannedGuestIds.toList());
    notifyListeners();
  }

  Future<void> unbanGuestReporter(String reporterId) async {
    _bannedGuestIds.remove(reporterId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bannedGuestIdsKey, _bannedGuestIds.toList());
    notifyListeners();
  }

  Future<void> updateStatus(String id, String status) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx < 0) return;
    _reports[idx] = _reports[idx].copyWith(status: status);
    if (_reportsApi.enabled) {
      await _reportsApi.updateStatus(id, status, accessToken: accessToken);
    } else {
      await _saveReports();
    }
    notifyListeners();
  }

  Future<void> vote(String id) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx < 0) return;
    _reports[idx] = _reports[idx].copyWith(votes: _reports[idx].votes + 1);
    if (_reportsApi.enabled) {
      await _reportsApi.incrementVote(id, accessToken: accessToken);
    } else {
      await _saveReports();
    }
    notifyListeners();
  }

  Future<void> editReport({
    required String id,
    required String title,
    required String description,
    required String category,
    required String quartier,
    required String address,
    double? latitude,
    double? longitude,
    List<String> nearbyOrganisations = const [],
  }) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx < 0) return;

    if (_reportsApi.enabled) {
      if (accessToken.isEmpty) {
        throw StateError('Authentification requise');
      }
      final updated = await _reportsApi.updateReport(
        id: id,
        title: title,
        description: description,
        category: category,
        quartier: quartier,
        address: address,
        latitude: latitude,
        longitude: longitude,
        nearbyOrganisations: nearbyOrganisations,
        accessToken: accessToken,
      );
      _reports[idx] = updated;
    } else {
      _reports[idx] = _reports[idx].copyWith(
        title: title,
        description: description,
        category: category,
        quartier: quartier,
        address: address,
        latitude: latitude,
        longitude: longitude,
        nearbyOrganisations: nearbyOrganisations,
      );
      await _saveReports();
    }

    notifyListeners();
  }

  Future<void> deleteReport(String id) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx < 0) return;

    if (_reportsApi.enabled) {
      if (accessToken.isEmpty) {
        throw StateError('Authentification requise');
      }
      await _reportsApi.deleteReport(id: id, accessToken: accessToken);
    }

    _reports.removeAt(idx);
    if (!_reportsApi.enabled) {
      await _saveReports();
    }
    notifyListeners();
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _reportsKey,
      jsonEncode(_reports.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveGuestProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _guestProfileKey,
      jsonEncode({
        'guestReporterId': guestReporterId,
        'quickReportsUsed': quickReportsUsed,
      }),
    );
  }

  String _generateGuestReporterId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final suffix = List.generate(
      8,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'QRP-$suffix';
  }

  String _extractUserIdFromAccessToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return '';
      var payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return map['user_id']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Map<String, String> _decodeProfile(dynamic rawProfile) {
    if (rawProfile is! Map) return {};
    return rawProfile.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
  }

  Future<void> changeLanguage(String newLanguage) async {
    if (newLanguage == _language) return;
    _language = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLanguage);
    notifyListeners();
  }

  Future<void> changeThemeMode(String newThemeMode) async {
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, newThemeMode);
    notifyListeners();
  }

  Future<void> refreshReports() async {
    if (_reportsApi.enabled) {
      try {
        final fromApi = isCitizen && accessToken.isNotEmpty
            ? await _reportsApi.fetchMyReports(accessToken: accessToken)
            : await _reportsApi.fetchReports(accessToken: accessToken);
        _reports
          ..clear()
          ..addAll(fromApi);
        notifyListeners();
      } catch (_) {
        // silently ignore refresh errors
      }
    }
  }
}

List<ReportModel> _seed() => const [
  ReportModel(
    id: '1',
    title: 'Nid de poule Lome Adidogome',
    description: 'Trou profond dangereux',
    category: 'route',
    status: 'en_cours',
    quartier: 'Lome - Adidogome',
    address: 'Avenue Freres sous le rond-point',
    date: '21/02/2026',
    votes: 14,
    reporterId: 'seed-org',
    reporterType: 'member',
  ),
  ReportModel(
    id: '2',
    title: 'Lampadaires eteints Kara Tomde',
    description: '3 lampadaires en panne',
    category: 'eclairage',
    status: 'nouveau',
    quartier: 'Kara - Tomde',
    address: 'Rue du marche central',
    date: '20/02/2026',
    votes: 8,
    reporterId: 'seed-citizen',
    reporterType: 'member',
  ),
  ReportModel(
    id: '3',
    title: 'Depot sauvage Sokode Komah',
    description: 'Sacs et dechets abandonnes',
    category: 'dechets',
    status: 'resolu',
    quartier: 'Sokode - Komah',
    address: 'Entree du marche de Komah',
    date: '18/02/2026',
    votes: 21,
    reporterId: 'seed-citizen',
    reporterType: 'member',
  ),
];
