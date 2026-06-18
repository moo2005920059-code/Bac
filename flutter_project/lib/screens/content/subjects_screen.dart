// ─── SUBJECTS SCREEN ──────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import 'flashcard_screen.dart';

class SubjectsScreen extends StatelessWidget {
  final SectionModel section;
  const SubjectsScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubjectModel>>(
      future: FirestoreService().getSubjects(section.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final subjects = snap.data ?? [];
        if (subjects.isEmpty) {
          return const Center(
              child: Text('لا توجد مواد', style: TextStyle(color: AppColors.textSecondary)));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14,
            mainAxisSpacing: 14, childAspectRatio: 1.1,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, i) => _SubjectCard(
            subject: subjects[i], section: section,
          ),
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final SectionModel section;
  const _SubjectCard({required this.subject, required this.section});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonsScreen(subject: subject, section: section),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: subject.color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: subject.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(subject.icon, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(height: 10),
            Text(subject.name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            if (subject.isFree)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('مجاني', style: TextStyle(color: AppColors.success, fontSize: 10)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── LESSONS SCREEN ───────────────────────────────────────────────────────────
class LessonsScreen extends StatelessWidget {
  final SubjectModel subject;
  final SectionModel section;
  const LessonsScreen({super.key, required this.subject, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(subject.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(subject.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<LessonModel>>(
                  future: FirestoreService().getLessons(section.id, subject.id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final lessons = snap.data ?? [];
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
                                sectionId: section.id,
                                sectionName: section.name,
                                sourceId: subject.id,
                                subSourceId: lesson.id,
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
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: subject.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text('${i + 1}',
                                        style: TextStyle(
                                            color: subject.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lesson.name,
                                          style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      if (lesson.cardCount > 0)
                                        Text('${lesson.cardCount} بطاقة',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: subject.color, size: 16),
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

// ─── SESSIONS SCREEN ──────────────────────────────────────────────────────────
class SessionsScreen extends StatelessWidget {
  final SectionModel section;
  const SessionsScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionModel>>(
      future: FirestoreService().getSessions(section.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final sessions = snap.data ?? [];
        if (sessions.isEmpty) {
          return const Center(
              child: Text('لا توجد دورات', style: TextStyle(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final session = sessions[i];
            final colors = [AppColors.primary, AppColors.secondary, const Color(0xFF00BCD4)];
            final color = colors[i % colors.length];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashCardScreen(
                    title: session.name,
                    sectionId: section.id,
                    sectionName: section.name,
                    sourceId: section.id,
                    subSourceId: session.id,
                    sourceName: section.name,
                    subSourceName: session.name,
                    sourceType: 'session',
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          if (session.cardCount > 0)
                            Text('${session.cardCount} سؤال',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          if (session.isFree)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('مجاني',
                                  style: TextStyle(color: AppColors.success, fontSize: 10)),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: color, size: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
