import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../services/firestore_service.dart';
import '../subjects/flashcard_screen.dart';

class SessionsScreen extends StatelessWidget {
  final YearModel year;

  const SessionsScreen({super.key, required this.year});

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
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('سنة ${year.year}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<SessionModel>>(
                  future: FirestoreService().getSessions(year.id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final sessions = snap.data ?? [];
                    if (sessions.isEmpty) {
                      return const Center(child: Text('لا توجد دورات متاحة', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                title: '${year.year} - ${session.name}',
                                subjectId: year.id,
                                lessonId: session.id,
                                sourceName: 'سنة ${year.year}',
                                subSourceName: session.name,
                                sourceType: 'year',
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
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                                  child: Center(child: Text('${i + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(session.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                                      if (session.subjectName != null)
                                        Text(session.subjectName!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                      if (session.cardCount > 0)
                                        Text('${session.cardCount} سؤال', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
