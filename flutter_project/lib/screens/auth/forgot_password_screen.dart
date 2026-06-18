import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(_emailController.text.trim());
    setState(() { _loading = false; _sent = success; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _sent ? _successView() : _formView(),
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
            ),
          ),
        ),
        const Spacer(),
        const Text('🔐', style: TextStyle(fontSize: 72), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Text('نسيت كلمة المرور؟',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text('أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _loading ? null : _reset,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إرسال رابط الاستعادة',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✅', style: TextStyle(fontSize: 80), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Text('تم الإرسال!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('تم إرسال رابط إعادة التعيين إلى:\n${_emailController.text}',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('العودة لتسجيل الدخول',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
