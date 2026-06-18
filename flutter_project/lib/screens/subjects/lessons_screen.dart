import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../services/firestore_service.dart';
import 'flashcard_screen.dart';

class LessonsScreen extends StatelessWidget {
  final SubjectModel subject;

  const LessonsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(subject.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(
                      subject.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              // Lessons List
              Expanded(
                child: FutureBuilder<List<LessonModel>>(
                  future: FirestoreService().getLessons(subject.id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final lessons = snap.data ?? [];
                    if (lessons.isEmpty) {
                      return const Center(
                        child: Text('لا توجد دروس متاحة', style: TextStyle(color: AppColors.textSecondary)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final lesson = lessons[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashCardScreen(
                                title: lesson.name,
                                subjectId: subject.id,
                                lessonId: lesson.id,
                                sourceName: subject.name,
                                subSourceName: lesson.name,
                                sourceType: 'subject',
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: subject.color.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: subject.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(color: subject.color, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lesson.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                                      if (lesson.cardCount > 0)
                                        Text('${lesson.cardCount} بطاقة', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: subject.color, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
