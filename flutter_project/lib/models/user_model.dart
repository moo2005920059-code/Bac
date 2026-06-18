import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? phone;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool isActive;
  final String? deviceId;
  final String? deviceName;
  final List<SavedCard> savedCards;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phone,
    this.subscriptionStart,
    this.subscriptionEnd,
    required this.isActive,
    this.deviceId,
    this.deviceName,
    required this.savedCards,
    required this.createdAt,
  });

  bool get isSubscriptionActive {
    if (subscriptionEnd == null) return false;
    return subscriptionEnd!.isAfter(DateTime.now());
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'],
      subscriptionStart: data['subscriptionStart'] != null
          ? (data['subscriptionStart'] as Timestamp).toDate()
          : null,
      subscriptionEnd: data['subscriptionEnd'] != null
          ? (data['subscriptionEnd'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      deviceId: data['deviceId'],
      deviceName: data['deviceName'],
      savedCards: (data['savedCards'] as List<dynamic>? ?? [])
          .map((e) => SavedCard.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'subscriptionStart':
          subscriptionStart != null ? Timestamp.fromDate(subscriptionStart!) : null,
      'subscriptionEnd':
          subscriptionEnd != null ? Timestamp.fromDate(subscriptionEnd!) : null,
      'isActive': isActive,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'savedCards': savedCards.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    bool? isActive,
    String? deviceId,
    String? deviceName,
    List<SavedCard>? savedCards,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      isActive: isActive ?? this.isActive,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      savedCards: savedCards ?? this.savedCards,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SavedCard {
  final String cardId;
  final String sourceType; // 'subject' or 'year'
  final String sourceId; // subjectId or yearId
  final String subSourceId; // lessonId or sessionId
  final String question;
  final String answer;
  final String sourceName; // subject/year name
  final String subSourceName; // lesson/session name
  final DateTime savedAt;

  SavedCard({
    required this.cardId,
    required this.sourceType,
    required this.sourceId,
    required this.subSourceId,
    required this.question,
    required this.answer,
    required this.sourceName,
    required this.subSourceName,
    required this.savedAt,
  });

  factory SavedCard.fromMap(Map<String, dynamic> map) {
    return SavedCard(
      cardId: map['cardId'] ?? '',
      sourceType: map['sourceType'] ?? 'subject',
      sourceId: map['sourceId'] ?? '',
      subSourceId: map['subSourceId'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      sourceName: map['sourceName'] ?? '',
      subSourceName: map['subSourceName'] ?? '',
      savedAt: map['savedAt'] != null
          ? (map['savedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'subSourceId': subSourceId,
      'question': question,
      'answer': answer,
      'sourceName': sourceName,
      'subSourceName': subSourceName,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}
