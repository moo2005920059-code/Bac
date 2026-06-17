import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../services/firestore_service.dart';
import 'sessions_screen.dart';

class YearsScreen extends StatelessWidget {
  const YearsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: const [
                  Text('📅', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Text('أسئلة السنوات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<YearModel>>(
                future: FirestoreService().getYears(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final years = snap.data ?? [];
                  if (years.isEmpty) {
                    return const Center(child: Text('لا توجد سنوات متاحة', style: TextStyle(color: AppColors.textSecondary)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: years.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final year = years[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SessionsScreen(year: year)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BCD4).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(child: Text('🎓', style: TextStyle(fontSize: 30))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('سنة ${year.year}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Text('امتحانات البكالوريا', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Color(0xFF00BCD4), size: 16),
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
    );
  }
}
