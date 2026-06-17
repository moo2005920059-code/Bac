import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class SubscriptionExpiredScreen extends StatelessWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 80), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                const Text(
                  'انتهى اشتراكك',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'لقد انتهت صلاحية اشتراكك.\nتواصل مع الإدارة لتجديد الاشتراك والاستمرار في التعلم.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.phone, color: AppColors.primary, size: 32),
                      SizedBox(height: 12),
                      Text('تواصل معنا', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('WhatsApp: +213 xxx xxx xxx', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceLight),
                  child: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
