import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── SECTIONS ─────────────────────────────────────────────────────────────
  Future<List<SectionModel>> getSections() async {
    final snap = await _db
        .collection('sections')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => SectionModel.fromFirestore(d)).toList();
  }

  // ─── SUBJECTS ─────────────────────────────────────────────────────────────
  Future<List<SubjectModel>> getSubjects(String sectionId) async {
    final snap = await _db
        .collection('sections')
        .doc(sectionId)
        .collection('subjects')
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => SubjectModel.fromFirestore(d, sectionId))
        .toList();
  }

  // ─── LESSONS ──────────────────────────────────────────────────────────────
  Future<List<LessonModel>> getLessons(
      String sectionId, String subjectId) async {
    final snap = await _db
        .collection('sections')
        .doc(sectionId)
        .collection('subjects')
        .doc(subjectId)
        .collection('lessons')
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => LessonModel.fromFirestore(d, subjectId, sectionId))
        .toList();
  }

  // ─── SUBJECT CARDS ────────────────────────────────────────────────────────
  Future<List<CardModel>> getSubjectCards(
      String sectionId, String subjectId, String lessonId) async {
    final snap = await _db
        .collection('sections')
        .doc(sectionId)
        .collection('subjects')
        .doc(subjectId)
        .collection('lessons')
        .doc(lessonId)
        .collection('cards')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => CardModel.fromFirestore(d)).toList();
  }

  // ─── SESSIONS ─────────────────────────────────────────────────────────────
  Future<List<SessionModel>> getSessions(String sectionId) async {
    final snap = await _db
        .collection('sections')
        .doc(sectionId)
        .collection('sessions')
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => SessionModel.fromFirestore(d, sectionId))
        .toList();
  }

  // ─── SESSION CARDS ────────────────────────────────────────────────────────
  Future<List<CardModel>> getSessionCards(
      String sectionId, String sessionId) async {
    final snap = await _db
        .collection('sections')
        .doc(sectionId)
        .collection('sessions')
        .doc(sessionId)
        .collection('cards')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => CardModel.fromFirestore(d)).toList();
  }

  // ─── ACTIVATION CODE ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> activateCode(
      String code, String userId) async {
    final snap = await _db
        .collection('codes')
        .where('code', isEqualTo: code.toUpperCase())
        .where('isUsed', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) {
      return {'success': false, 'error': 'الكود غير صحيح أو مستخدم مسبقاً'};
    }

    final codeDoc = snap.docs.first;
    final codeData = codeDoc.data();

    final expiryDate = (codeData['expiryDate'] as Timestamp).toDate();
    if (expiryDate.isBefore(DateTime.now())) {
      return {'success': false, 'error': 'انتهت صلاحية هذا الكود'};
    }

    // Mark code as used
    await _db.collection('codes').doc(codeDoc.id).update({
      'isUsed': true,
      'usedBy': userId,
      'usedAt': FieldValue.serverTimestamp(),
    });

    // Update user
    await _db.collection('users').doc(userId).update({
      'activationCode': code.toUpperCase(),
      'activatedAt': FieldValue.serverTimestamp(),
      'expiryDate': codeData['expiryDate'],
      'sectionId': codeData['sectionId'] ?? '',
    });

    return {
      'success': true,
      'expiryDate': expiryDate,
      'sectionId': codeData['sectionId'] ?? '',
    };
  }

  // ─── SAVE CARD ────────────────────────────────────────────────────────────
  Future<void> saveCard(String userId, SavedCard card) async {
    await _db.collection('users').doc(userId).update({
      'savedCards': FieldValue.arrayUnion([card.toMap()]),
    });
  }

  Future<void> removeSavedCard(String userId, SavedCard card) async {
    await _db.collection('users').doc(userId).update({
      'savedCards': FieldValue.arrayRemove([card.toMap()]),
    });
  }

  // ─── SEED DATA ────────────────────────────────────────────────────────────
  Future<void> seedSections() async {
    final sections = [
      {'name': 'بكالوريا علمي', 'type': 'sci_bac', 'order': 1, 'isActive': true},
      {'name': 'بكالوريا أدبي', 'type': 'lit_bac', 'order': 2, 'isActive': true},
      {'name': 'تاسع', 'type': 'ninth', 'order': 3, 'isActive': true},
    ];

    for (final s in sections) {
      await _db.collection('sections').add(s);
    }
  }
}
