import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── SUBJECTS ───────────────────────────────────────────────
  Future<List<SubjectModel>> getSubjects() async {
    final snap = await _db
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList();
  }

  // ─── LESSONS ────────────────────────────────────────────────
  Future<List<LessonModel>> getLessons(String subjectId) async {
    final snap = await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('lessons')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => LessonModel.fromFirestore(d, subjectId)).toList();
  }

  // ─── CARDS (Subject) ────────────────────────────────────────
  Future<List<CardModel>> getSubjectCards(
      String subjectId, String lessonId) async {
    final snap = await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('lessons')
        .doc(lessonId)
        .collection('cards')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => CardModel.fromFirestore(d)).toList();
  }

  // ─── YEARS ──────────────────────────────────────────────────
  Future<List<YearModel>> getYears() async {
    final snap = await _db
        .collection('years')
        .where('isActive', isEqualTo: true)
        .orderBy('year', descending: true)
        .get();
    return snap.docs.map((d) => YearModel.fromFirestore(d)).toList();
  }

  // ─── SESSIONS ───────────────────────────────────────────────
  Future<List<SessionModel>> getSessions(String yearId) async {
    final snap = await _db
        .collection('years')
        .doc(yearId)
        .collection('sessions')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => SessionModel.fromFirestore(d, yearId)).toList();
  }

  // ─── CARDS (Year/Session) ───────────────────────────────────
  Future<List<CardModel>> getSessionCards(
      String yearId, String sessionId) async {
    final snap = await _db
        .collection('years')
        .doc(yearId)
        .collection('sessions')
        .doc(sessionId)
        .collection('cards')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => CardModel.fromFirestore(d)).toList();
  }

  // ─── SEED DATA (run once to populate) ─────────────────────
  Future<void> seedSampleData() async {
    final batch = _db.batch();

    // Add Physics subject
    final physicsRef = _db.collection('subjects').doc('physics');
    batch.set(physicsRef, {
      'name': 'فيزياء',
      'icon': '⚛️',
      'colorIndex': 1,
      'order': 1,
      'isActive': true,
    });

    // Physics lessons
    final pendulumRef = physicsRef.collection('lessons').doc('pendulum');
    batch.set(pendulumRef, {'name': 'النواس الثقلي', 'order': 1, 'cardCount': 3});
    batch.set(pendulumRef.collection('cards').doc('c1'), {
      'question': 'ما هو تعريف النواس الثقلي؟',
      'answer': 'النواس الثقلي هو جسم ثقيل (ثقل) معلق بخيط خفيف عديم الوزن، يتأرجح في مستوى عمودي تحت تأثير الجاذبية الأرضية.',
      'order': 1,
    });
    batch.set(pendulumRef.collection('cards').doc('c2'), {
      'question': 'ما هي صيغة دور النواس الثقلي؟',
      'answer': 'T = 2π√(L/g)\nحيث:\n• T: الدور بالثانية\n• L: طول الخيط بالمتر\n• g: تسارع الجاذبية (9.8 m/s²)',
      'order': 2,
    });
    batch.set(pendulumRef.collection('cards').doc('c3'), {
      'question': 'ما هي شروط التذبذب التوافقي للنواس الثقلي؟',
      'answer': 'يتذبذب النواس الثقلي توافقياً إذا كانت زاوية الانحراف صغيرة (أقل من 10°)، بحيث يمكن التقريب: sin θ ≈ θ',
      'order': 3,
    });

    // Add Math subject
    final mathRef = _db.collection('subjects').doc('math');
    batch.set(mathRef, {
      'name': 'رياضيات',
      'icon': '📐',
      'colorIndex': 0,
      'order': 2,
      'isActive': true,
    });

    final limitsRef = mathRef.collection('lessons').doc('limits');
    batch.set(limitsRef, {'name': 'النهايات', 'order': 1, 'cardCount': 3});
    batch.set(limitsRef.collection('cards').doc('c1'), {
      'question': 'ما هو تعريف نهاية دالة؟',
      'answer': 'نهاية الدالة f(x) عند x=a هي القيمة L التي تقترب منها f(x) كلما اقترب x من a، ويُكتب: lim(x→a) f(x) = L',
      'order': 1,
    });

    // Add Year 2024
    final year2024Ref = _db.collection('years').doc('2024');
    batch.set(year2024Ref, {'year': 2024, 'isActive': true});

    final session1Ref = year2024Ref.collection('sessions').doc('session1');
    batch.set(session1Ref, {
      'name': 'الدورة الأولى',
      'subjectId': 'physics',
      'subjectName': 'فيزياء',
      'order': 1,
      'cardCount': 2,
    });
    batch.set(session1Ref.collection('cards').doc('c1'), {
      'question': 'سؤال فيزياء دورة 2024 الأولى: احسب دور نواس طول خيطه 25 cm',
      'answer': 'T = 2π√(L/g) = 2π√(0.25/9.8) ≈ 1 ثانية',
      'order': 1,
    });

    await batch.commit();
  }
}
