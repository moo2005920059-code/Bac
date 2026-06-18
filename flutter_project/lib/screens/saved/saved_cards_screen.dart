import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';

class SavedCardsScreen extends StatelessWidget {
  const SavedCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final saved = auth.user?.savedCards ?? [];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [
                          Text('🔖', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 12),
                          Text('المحفوظات',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${saved.length}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  if (saved.isEmpty)
                    const Expanded(child: _EmptyState())
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: saved.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) =>
                            _SavedCardItem(card: saved[i], auth: auth),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SavedCardItem extends StatefulWidget {
  final SavedCard card;
  final AuthProvider auth;
  const _SavedCardItem({required this.card, required this.auth});

  @override
  State<_SavedCardItem> createState() => _SavedCardItemState();
}

class _SavedCardItemState extends State<_SavedCardItem> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.card.sectionName} | ${widget.card.subSourceName}',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                  ),
                ),
              ],
            ),
          ),

          // Question
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.card.questionText.isNotEmpty)
                  Text(widget.card.questionText,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.5)),
                if (widget.card.questionImageUrl != null &&
                    widget.card.questionImageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(widget.card.questionImageUrl!,
                        height: 150, fit: BoxFit.cover),
                  ),
                ],
              ],
            ),
          ),

          // Show Answer Button
          GestureDetector(
            onTap: () => setState(() => _showAnswer = !_showAnswer),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _showAnswer
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _showAnswer ? 'إخفاء الجواب' : 'إظهار الجواب',
                style: TextStyle(
                    color: _showAnswer ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          if (_showAnswer) ...[
            const Divider(color: AppColors.surfaceLight, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.card.answerText.isNotEmpty)
                    Text(widget.card.answerText,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                  if (widget.card.answerImageUrl != null &&
                      widget.card.answerImageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(widget.card.answerImageUrl!,
                          height: 150, fit: BoxFit.cover),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف من المحفوظات',
            style: TextStyle(color: AppColors.textPrimary), textAlign: TextAlign.center),
        content: const Text('هل تريد حذف هذه البطاقة؟',
            style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); widget.auth.removeSavedCard(widget.card); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Center(child: Text('🔖', style: TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 24),
          const Text('لا توجد بطاقات محفوظة',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('اضغط على 🔖 في أي بطاقة لحفظها',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
