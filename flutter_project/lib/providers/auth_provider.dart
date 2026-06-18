import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isActivated => _user?.isActivated ?? false;

  AuthProvider() { _init(); }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        final userData = await _authService.getUserData(firebaseUser.uid);
        if (userData != null) {
          _user = userData;
          _status = AuthStatus.authenticated;
          _listenToUser(firebaseUser.uid);
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
      notifyListeners();
    });
  }

  void _listenToUser(String uid) {
    _authService.userStream(uid).listen((userData) {
      if (userData != null) {
        _user = userData;
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
        _status = AuthStatus.authenticated;
        _listenToUser(_user!.uid);
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = _getErrorMsg(result['error']);
      }
      notifyListeners();
      return result;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false};
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
        email: email, password: password,
        fullName: fullName, phone: phone,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
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

  Future<Map<String, dynamic>> activateCode(String code) async {
    if (_user == null) return {'success': false, 'error': 'لم يتم تسجيل الدخول'};
    final result = await _firestoreService.activateCode(code, _user!.uid);
    if (result['success'] == true) {
      final updated = await _authService.getUserData(_user!.uid);
      if (updated != null) {
        _user = updated;
        notifyListeners();
      }
    }
    return result;
  }

  Future<void> saveCard(SavedCard card) async {
    if (_user == null) return;
    final alreadySaved = _user!.savedCards.any((c) => c.cardId == card.cardId);
    if (alreadySaved) return;
    await _firestoreService.saveCard(_user!.uid, card);
  }

  Future<void> removeSavedCard(SavedCard card) async {
    if (_user == null) return;
    await _firestoreService.removeSavedCard(_user!.uid, card);
  }

  bool isCardSaved(String cardId) =>
      _user?.savedCards.any((c) => c.cardId == cardId) ?? false;

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _getErrorMsg(String? code) {
    switch (code) {
      case 'account_disabled': return 'تم تعطيل هذا الحساب';
      case 'device_mismatch': return 'هذا الحساب مرتبط بجهاز آخر';
      default: return 'حدث خطأ غير متوقع';
    }
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}
