import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─── COLORS ──────────────────────────────────────────────────────────────────
const List<Color> kSubjectColors = [
  Color(0xFF6C63FF),
  Color(0xFF00BCD4),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF2196F3),
  Color(0xFFFF5722),
];

// ─── SECTION MODEL ────────────────────────────────────────────────────────────
class SectionModel {
  final String id;
  final String name;
  final String type;
  final int order;
  final bool isActive;

  SectionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.order,
    required this.isActive,
  });

  factory SectionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SectionModel(
      id: doc.id,
      name: d['name'] ?? '',
      type: d['type'] ?? '',
      order: d['order'] ?? 0,
      isActive: d['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'order': order,
        'isActive': isActive,
      };

  String get emoji {
    switch (type) {
      case 'sci_bac': return '🔬';
      case 'lit_bac': return '📖';
      case 'ninth': return '🎓';
      default: return '📚';
    }
  }
}

// ─── SUBJECT MODEL ────────────────────────────────────────────────────────────
class SubjectModel {
  final String id;
  final String sectionId;
  final String name;
  final String icon;
  final int colorIndex;
  final int order;
  final bool isFree;

  SubjectModel({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.icon,
    required this.colorIndex,
    required this.order,
    required this.isFree,
  });

  Color get color => kSubjectColors[colorIndex % kSubjectColors.length];

  factory SubjectModel.fromFirestore(DocumentSnapshot doc, String sectionId) {
    final d = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      sectionId: sectionId,
      name: d['name'] ?? '',
      icon: d['icon'] ?? '📚',
      colorIndex: d['colorIndex'] ?? 0,
      order: d['order'] ?? 0,
      isFree: d['isFree'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'icon': icon,
        'colorIndex': colorIndex,
        'order': order,
        'isFree': isFree,
      };
}

// ─── LESSON MODEL ─────────────────────────────────────────────────────────────
class LessonModel {
  final String id;
  final String subjectId;
  final String sectionId;
  final String name;
  final int order;
  final int cardCount;

  LessonModel({
    required this.id,
    required this.subjectId,
    required this.sectionId,
    required this.name,
    required this.order,
    required this.cardCount,
  });

  factory LessonModel.fromFirestore(
      DocumentSnapshot doc, String subjectId, String sectionId) {
    final d = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      subjectId: subjectId,
      sectionId: sectionId,
      name: d['name'] ?? '',
      order: d['order'] ?? 0,
      cardCount: d['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'order': order,
        'cardCount': cardCount,
      };
}

// ─── SESSION MODEL ────────────────────────────────────────────────────────────
class SessionModel {
  final String id;
  final String sectionId;
  final String name;
  final int order;
  final bool isFree;
  final int cardCount;

  SessionModel({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.order,
    required this.isFree,
    required this.cardCount,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc, String sectionId) {
    final d = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      sectionId: sectionId,
      name: d['name'] ?? '',
      order: d['order'] ?? 0,
      isFree: d['isFree'] ?? false,
      cardCount: d['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'order': order,
        'isFree': isFree,
        'cardCount': cardCount,
      };
}

// ─── CARD MODEL ───────────────────────────────────────────────────────────────
class CardModel {
  final String id;
  final String questionText;
  final String? questionImageUrl;
  final String answerText;
  final String? answerImageUrl;
  final int order;

  CardModel({
    required this.id,
    required this.questionText,
    this.questionImageUrl,
    required this.answerText,
    this.answerImageUrl,
    required this.order,
  });

  bool get hasQuestionImage =>
      questionImageUrl != null && questionImageUrl!.isNotEmpty;
  bool get hasAnswerImage =>
      answerImageUrl != null && answerImageUrl!.isNotEmpty;

  factory CardModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CardModel(
      id: doc.id,
      questionText: d['questionText'] ?? '',
      questionImageUrl: d['questionImageUrl'],
      answerText: d['answerText'] ?? '',
      answerImageUrl: d['answerImageUrl'],
      order: d['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'questionText': questionText,
        'questionImageUrl': questionImageUrl ?? '',
        'answerText': answerText,
        'answerImageUrl': answerImageUrl ?? '',
        'order': order,
      };
}

// ─── SAVED CARD MODEL ─────────────────────────────────────────────────────────
class SavedCard {
  final String cardId;
  final String sectionId;
  final String sectionName;
  final String sourceName;
  final String subSourceName;
  final String sourceType; // 'subject' or 'session'
  final String questionText;
  final String? questionImageUrl;
  final String answerText;
  final String? answerImageUrl;
  final DateTime savedAt;

  SavedCard({
    required this.cardId,
    required this.sectionId,
    required this.sectionName,
    required this.sourceName,
    required this.subSourceName,
    required this.sourceType,
    required this.questionText,
    this.questionImageUrl,
    required this.answerText,
    this.answerImageUrl,
    required this.savedAt,
  });

  factory SavedCard.fromMap(Map<String, dynamic> map) {
    return SavedCard(
      cardId: map['cardId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      sectionName: map['sectionName'] ?? '',
      sourceName: map['sourceName'] ?? '',
      subSourceName: map['subSourceName'] ?? '',
      sourceType: map['sourceType'] ?? 'subject',
      questionText: map['questionText'] ?? '',
      questionImageUrl: map['questionImageUrl'],
      answerText: map['answerText'] ?? '',
      answerImageUrl: map['answerImageUrl'],
      savedAt: map['savedAt'] != null
          ? (map['savedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'cardId': cardId,
        'sectionId': sectionId,
        'sectionName': sectionName,
        'sourceName': sourceName,
        'subSourceName': subSourceName,
        'sourceType': sourceType,
        'questionText': questionText,
        'questionImageUrl': questionImageUrl ?? '',
        'answerText': answerText,
        'answerImageUrl': answerImageUrl ?? '',
        'savedAt': Timestamp.fromDate(savedAt),
      };
}

// ─── USER MODEL ───────────────────────────────────────────────────────────────
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? phone;
  final bool isActive;
  final String? deviceId;
  final String? deviceName;
  final String? activationCode;
  final DateTime? activatedAt;
  final DateTime? expiryDate;
  final String? sectionId;
  final List<SavedCard> savedCards;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phone,
    required this.isActive,
    this.deviceId,
    this.deviceName,
    this.activationCode,
    this.activatedAt,
    this.expiryDate,
    this.sectionId,
    required this.savedCards,
    required this.createdAt,
  });

  bool get isActivated => expiryDate != null && expiryDate!.isAfter(DateTime.now());

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: d['email'] ?? '',
      fullName: d['fullName'] ?? '',
      phone: d['phone'],
      isActive: d['isActive'] ?? true,
      deviceId: d['deviceId'],
      deviceName: d['deviceName'],
      activationCode: d['activationCode'],
      activatedAt: d['activatedAt'] != null
          ? (d['activatedAt'] as Timestamp).toDate()
          : null,
      expiryDate: d['expiryDate'] != null
          ? (d['expiryDate'] as Timestamp).toDate()
          : null,
      sectionId: d['sectionId'],
      savedCards: (d['savedCards'] as List<dynamic>? ?? [])
          .map((e) => SavedCard.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'isActive': isActive,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'activationCode': activationCode,
        'activatedAt': activatedAt != null ? Timestamp.fromDate(activatedAt!) : null,
        'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        'sectionId': sectionId,
        'savedCards': savedCards.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
