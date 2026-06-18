import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

      final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        isActive: true,
        deviceId: deviceId,
        savedCards: [],
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

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
      final currentDeviceId = 'device_${user.uid}';

      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw Exception('الحساب غير موجود');

      final userModel = UserModel.fromFirestore(userDoc);

      if (!userModel.isActive) {
        await _auth.signOut();
        return {'success': false, 'error': 'account_disabled'};
      }

      // Check device
      if (userModel.deviceId != null && userModel.deviceId!.isNotEmpty &&
          !userModel.deviceId!.startsWith('device_${user.uid}')) {
        if (userModel.deviceId != currentDeviceId) {
          await _auth.signOut();
          return {'success': false, 'error': 'device_mismatch'};
        }
      }

      await _db.collection('users').doc(user.uid).update({
        'deviceId': currentDeviceId,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'user': userModel};
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async => await _auth.signOut();

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password': return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use': return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password': return 'كلمة المرور ضعيفة (8 أحرف على الأقل)';
      case 'invalid-email': return 'البريد الإلكتروني غير صالح';
      case 'too-many-requests': return 'محاولات كثيرة، حاول لاحقاً';
      default: return 'حدث خطأ: ${e.message}';
    }
  }
}
