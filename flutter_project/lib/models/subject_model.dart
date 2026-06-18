import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SubjectModel {
  final String id;
  final String name;
  final String icon;
  final int colorIndex;
  final int order;
  final bool isActive;

  SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorIndex,
    required this.order,
    required this.isActive,
  });

  Color get color => AppColors.subjectColors[colorIndex % AppColors.subjectColors.length];

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '📚',
      colorIndex: data['colorIndex'] ?? 0,
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'icon': icon,
        'colorIndex': colorIndex,
        'order': order,
        'isActive': isActive,
      };
}

class LessonModel {
  final String id;
  final String subjectId;
  final String name;
  final int order;
  final int cardCount;

  LessonModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.order,
    required this.cardCount,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc, String subjectId) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      subjectId: subjectId,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      cardCount: data['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'order': order,
        'cardCount': cardCount,
      };
}

class CardModel {
  final String id;
  final String question;
  final String answer;
  final int order;

  CardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.order,
  });

  factory CardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CardModel(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'answer': answer,
        'order': order,
      };
}

class YearModel {
  final String id;
  final int year;
  final bool isActive;

  YearModel({
    required this.id,
    required this.year,
    required this.isActive,
  });

  factory YearModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return YearModel(
      id: doc.id,
      year: data['year'] ?? 2024,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {'year': year, 'isActive': isActive};
}

class SessionModel {
  final String id;
  final String yearId;
  final String name;
  final String? subjectId;
  final String? subjectName;
  final int order;
  final int cardCount;

  SessionModel({
    required this.id,
    required this.yearId,
    required this.name,
    this.subjectId,
    this.subjectName,
    required this.order,
    required this.cardCount,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc, String yearId) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      yearId: yearId,
      name: data['name'] ?? '',
      subjectId: data['subjectId'],
      subjectName: data['subjectName'],
      order: data['order'] ?? 0,
      cardCount: data['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'order': order,
        'cardCount': cardCount,
      };
}
