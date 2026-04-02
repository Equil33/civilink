import 'package:flutter/foundation.dart';

import '../store/app_store.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider(this._store);

  AppStore _store;
  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  void bindStore(AppStore store) {
    _store = store;
  }

  Future<void> submitReport({
    required String title,
    required String description,
    required String category,
    required String quartier,
    required int quartierId,
    required String address,
    double? latitude,
    double? longitude,
    bool isQuickReport = false,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _store.addReport(
        title: title,
        description: description,
        category: category,
        quartier: quartier,
        quartierId: quartierId,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isQuickReport: isQuickReport,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
