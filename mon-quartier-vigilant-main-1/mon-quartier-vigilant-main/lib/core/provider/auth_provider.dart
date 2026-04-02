import 'package:flutter/foundation.dart';

import '../store/app_store.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._store);

  AppStore _store;
  bool _isRegisteringCitizen = false;
  bool _isLoggingIn = false;
  String? _error;

  bool get isRegisteringCitizen => _isRegisteringCitizen;
  bool get isLoggingIn => _isLoggingIn;
  String? get error => _error;

  void bindStore(AppStore store) {
    _store = store;
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
    if (_isRegisteringCitizen) return;
    _isRegisteringCitizen = true;
    _error = null;
    notifyListeners();

    try {
      await _store.registerCitizen(
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
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isRegisteringCitizen = false;
      notifyListeners();
    }
  }

  Future<void> loginWithCredentials({
    required String email,
    required String password,
    required String role,
    String? orgType,
  }) async {
    if (_isLoggingIn) return;
    _isLoggingIn = true;
    _error = null;
    notifyListeners();

    try {
      await _store.loginWithCredentials(
        email: email,
        password: password,
        role: role,
        orgType: orgType,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }
}
