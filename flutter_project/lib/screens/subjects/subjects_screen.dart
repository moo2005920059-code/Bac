import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../services/firestore_service.dart';
import 'lessons_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<SubjectModel>>(
                future: FirestoreService().getSubjects(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('خطأ: ${snap.error}', style: const TextStyle(color: AppColors.error)),
                    );
                  }
                  final subjects = snap.data ?? [];
                  if (subjects.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مواد متاحة', style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, i) => _SubjectCard(subject: subjects[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: const [
          Text('📚', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Text(
            'المواد الدراسية',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LessonsScreen(subject: subject)),
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: subject.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(subject.icon, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 12),
            Text(
              subject.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
