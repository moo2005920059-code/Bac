import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'device_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceService _deviceService = DeviceService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(fullName);

      final deviceId = await _deviceService.getDeviceId();
      final deviceName = await _deviceService.getDeviceName();

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        isActive: true,
        deviceId: deviceId,
        deviceName: deviceName,
        savedCards: [],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      final currentDeviceId = await _deviceService.getDeviceId();
      final currentDeviceName = await _deviceService.getDeviceName();

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('حساب المستخدم غير موجود');
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Check if account is active
      if (!userModel.isActive) {
        await _auth.signOut();
        return {'success': false, 'error': 'account_disabled'};
      }

      // Check subscription
      if (!userModel.isSubscriptionActive) {
        // Allow login but flag subscription expired
        return {'success': true, 'subscriptionExpired': true, 'user': userModel};
      }

      // Check device
      if (userModel.deviceId != null && userModel.deviceId!.isNotEmpty) {
        if (userModel.deviceId != currentDeviceId) {
          await _auth.signOut();
          return {'success': false, 'error': 'device_mismatch'};
        }
      } else {
        // First login - save device
        await _firestore.collection('users').doc(user.uid).update({
          'deviceId': currentDeviceId,
          'deviceName': currentDeviceName,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      // Update last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'subscriptionExpired': false, 'user': userModel};
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get User Data
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Stream User Data
  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // Save Card
  Future<void> saveCard(String uid, SavedCard card) async {
    await _firestore.collection('users').doc(uid).update({
      'savedCards': FieldValue.arrayUnion([card.toMap()]),
    });
  }

  // Remove Saved Card
  Future<void> removeSavedCard(String uid, SavedCard card) async {
    await _firestore.collection('users').doc(uid).update({
      'savedCards': FieldValue.arrayRemove([card.toMap()]),
    });
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
