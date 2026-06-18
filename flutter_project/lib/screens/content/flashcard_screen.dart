import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class FlashCardScreen extends StatefulWidget {
  final String title;
  final String sectionId;
  final String sectionName;
  final String sourceId;
  final String subSourceId;
  final String sourceName;
  final String subSourceName;
  final String sourceType;

  const FlashCardScreen({
    super.key,
    required this.title,
    required this.sectionId,
    required this.sectionName,
    required this.sourceId,
    required this.subSourceId,
    required this.sourceName,
    required this.subSourceName,
    required this.sourceType,
  });

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  List<CardModel> _cards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      List<CardModel> cards;
      if (widget.sourceType == 'subject') {
        cards = await FirestoreService().getSubjectCards(
            widget.sectionId, widget.sourceId, widget.subSourceId);
      } else {
        cards = await FirestoreService()
            .getSessionCards(widget.sectionId, widget.subSourceId);
      }
      setState(() { _cards = cards; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _next() {
    if (_currentIndex < _cards.length - 1) {
      setState(() { _currentIndex++; _showAnswer = false; });
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() { _currentIndex--; _showAnswer = false; });
    }
  }

  Future<void> _toggleSave(AuthProvider auth) async {
    if (_cards.isEmpty) return;
    final card = _cards[_currentIndex];
    final savedCard = SavedCard(
      cardId: card.id,
      sectionId: widget.sectionId,
      sectionName: widget.sectionName,
      sourceName: widget.sourceName,
      subSourceName: widget.subSourceName,
      sourceType: widget.sourceType,
      questionText: card.questionText,
      questionImageUrl: card.questionImageUrl,
      answerText: card.answerText,
      answerImageUrl: card.answerImageUrl,
      savedAt: DateTime.now(),
    );

    if (auth.isCardSaved(card.id)) {
      await auth.removeSavedCard(savedCard);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف البطاقة'), backgroundColor: AppColors.error),
      );
    } else {
      await auth.saveCard(savedCard);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ البطاقة'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (_cards.isEmpty)
                const Expanded(child: Center(child: Text('لا توجد بطاقات', style: TextStyle(color: AppColors.textSecondary))))
              else ...[
                _buildProgress(),
                Expanded(child: _buildCard()),
                _buildControls(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
          Expanded(
            child: Text(widget.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (_cards.isEmpty) return const SizedBox();
              final isSaved = auth.isCardSaved(_cards[_currentIndex].id);
              return GestureDetector(
                onTap: () => _toggleSave(auth),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                  child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppColors.primary : AppColors.textHint),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentIndex + 1} / ${_cards.length}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('${((_currentIndex + 1) / _cards.length * 100).toInt()}%',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              backgroundColor: AppColors.surfaceLight,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final card = _cards[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => setState(() => _showAnswer = !_showAnswer),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _showAnswer ? AppColors.primary.withOpacity(0.6) : AppColors.surfaceLight,
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Question Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('السؤال',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                // Question Text
                if (card.questionText.isNotEmpty)
                  Text(card.questionText,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, height: 1.6),
                      textAlign: TextAlign.center),

                // Question Image
                if (card.hasQuestionImage) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      card.questionImageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) =>
                          progress == null ? child : const CircularProgressIndicator(color: AppColors.primary),
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: AppColors.textHint, size: 48),
                    ),
                  ),
                ],

                if (_showAnswer) ...[
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.surfaceLight),
                  const SizedBox(height: 16),

                  // Answer Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('الجواب',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),

                  // Answer Text
                  if (card.answerText.isNotEmpty)
                    Text(card.answerText,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, height: 1.7),
                        textAlign: TextAlign.center),

                  // Answer Image
                  if (card.hasAnswerImage) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        card.answerImageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (ctx, child, progress) =>
                            progress == null ? child : const CircularProgressIndicator(color: AppColors.primary),
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: AppColors.textHint, size: 48),
                      ),
                    ),
                  ],
                ] else ...[
                  const SizedBox(height: 32),
                  const Icon(Icons.touch_app_rounded, color: AppColors.textHint, size: 36),
                  const SizedBox(height: 8),
                  const Text('اضغط لإظهار الجواب',
                      style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _currentIndex > 0 ? _previous : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _currentIndex > 0 ? AppColors.surface : AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 16,
                        color: _currentIndex > 0 ? AppColors.textPrimary : AppColors.textHint),
                    const SizedBox(width: 6),
                    Text('السابق',
                        style: TextStyle(
                            color: _currentIndex > 0 ? AppColors.textPrimary : AppColors.textHint,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: _showAnswer
                      ? const LinearGradient(colors: [AppColors.success, Color(0xFF2E7D32)])
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _showAnswer ? 'إخفاء الجواب' : 'إظهار الجواب',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _currentIndex < _cards.length - 1 ? _next : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _currentIndex < _cards.length - 1 ? AppColors.surface : AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('التالي',
                        style: TextStyle(
                            color: _currentIndex < _cards.length - 1 ? AppColors.textPrimary : AppColors.textHint,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 16,
                        color: _currentIndex < _cards.length - 1 ? AppColors.textPrimary : AppColors.textHint),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
