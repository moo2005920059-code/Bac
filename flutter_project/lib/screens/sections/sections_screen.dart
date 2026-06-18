import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../content/subjects_screen.dart';
import '../content/sessions_screen.dart';
import '../activation/activation_screen.dart';

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: FutureBuilder<List<SectionModel>>(
                  future: FirestoreService().getSections(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final sections = snap.data ?? [];
                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) =>
                          _SectionCard(section: sections[i]),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أهلاً 👋',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text(auth.user?.fullName ?? 'طالب',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => GestureDetector(
              onTap: () => _showMenu(context, auth),
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(auth.user?.fullName ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(auth.user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            if (!auth.isActivated)
              ListTile(
                leading: const Icon(Icons.vpn_key, color: AppColors.primary),
                title: const Text('تفعيل الاشتراك', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivationScreen()));
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
              onTap: () { Navigator.pop(ctx); auth.logout(); },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SectionModel section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLocked = !auth.isActivated;
        return GestureDetector(
          onTap: () => _onTap(context, auth, isLocked),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(section.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      if (isLocked)
                        const Text('مقفل - يحتاج تفعيل',
                            style: TextStyle(color: AppColors.error, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(isLocked ? Icons.lock : Icons.arrow_forward_ios,
                    color: isLocked ? AppColors.error : AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context, AuthProvider auth, bool isLocked) {
    if (isLocked) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ActivationScreen()));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SectionDetailScreen(section: section),
      ),
    );
  }
}

// ─── Section Detail (دورات + مواد) ───────────────────────────────────────────
class SectionDetailScreen extends StatefulWidget {
  final SectionModel section;
  const SectionDetailScreen({super.key, required this.section});

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(widget.section.emoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(widget.section.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: '📅 الدورات'),
                    Tab(text: '📚 المواد'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SessionsScreen(section: widget.section),
                    SubjectsScreen(section: widget.section),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
