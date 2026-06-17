import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _subscriptionExpired = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get subscriptionExpired => _subscriptionExpired;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        notifyListeners();
      } else {
        final userData = await _authService.getUserData(firebaseUser.uid);
        if (userData != null) {
          _user = userData;
          _subscriptionExpired = !userData.isSubscriptionActive;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
        notifyListeners();
      }
    });
  }

  // Listen to real-time user changes
  void listenToUser(String uid) {
    _authService.userStream(uid).listen((userData) {
      if (userData != null) {
        _user = userData;
        _subscriptionExpired = !userData.isSubscriptionActive;
        notifyListeners();
      }
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result['success'] == true) {
        _user = result['user'];
        _subscriptionExpired = result['subscriptionExpired'] ?? false;
        _status = AuthStatus.authenticated;
        listenToUser(_user!.uid);
        notifyListeners();
        return result;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = _getErrorMessage(result['error']);
        notifyListeners();
        return result;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      _subscriptionExpired = true; // New users have no subscription
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> saveCard(SavedCard card) async {
    if (_user == null) return;
    // Check if already saved
    final alreadySaved = _user!.savedCards.any((c) => c.cardId == card.cardId);
    if (alreadySaved) return;
    await _authService.saveCard(_user!.uid, card);
  }

  Future<void> removeSavedCard(SavedCard card) async {
    if (_user == null) return;
    await _authService.removeSavedCard(_user!.uid, card);
  }

  bool isCardSaved(String cardId) {
    return _user?.savedCards.any((c) => c.cardId == cardId) ?? false;
  }

  String _getErrorMessage(String? code) {
    switch (code) {
      case 'account_disabled':
        return 'تم تعطيل هذا الحساب. تواصل مع الإدارة.';
      case 'device_mismatch':
        return 'هذا الحساب مرتبط بجهاز آخر. تواصل مع الإدارة لإعادة تعيين الجهاز.';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
