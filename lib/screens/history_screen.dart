import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../utils/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (provider.history.isEmpty) {
          return _EmptyState();
        }

        return Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${provider.history.length} calculations',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showClearDialog(context, provider),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: provider.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = provider.history[index];
                  return _HistoryCard(
                    history: item,
                    onDelete: () => provider.deleteHistory(item.id!),
                    onPin: () =>
                        provider.togglePin(item.id!, !item.isPinned),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Clear History',
          style: GoogleFonts.spaceGrotesk(
              color: AppTheme.onSurface, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will permanently delete all calculation history.',
          style:
              GoogleFonts.manrope(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.manrope(
                    color: AppTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: Text('Clear',
                style: GoogleFonts.manrope(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_outlined,
                size: 32, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start calculating to see your history here',
            style: GoogleFonts.manrope(
                fontSize: 13, color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CalculationHistory history;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const _HistoryCard({
    required this.history,
    required this.onDelete,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final resultText = _getResultText();
    final resultColor = _getResultColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: history.isPinned
            ? AppTheme.surfaceContainerHigh
            : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getAvatarColor().withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getAvatarLabel(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _getAvatarColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.name,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy · HH:mm')
                      .format(history.timestamp),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resultText,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: resultColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onPin,
                child: Icon(
                  history.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  size: 18,
                  color: history.isPinned
                      ? const Color(0xFFFFD600)
                      : AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAvatarLabel() {
    switch (history.type) {
      case 'basic_calculator':
        return '=';
      case 'compound_interest':
        return '%';
      default:
        return '?';
    }
  }

  Color _getAvatarColor() {
    switch (history.type) {
      case 'basic_calculator':
        return AppTheme.primary;
      case 'compound_interest':
        return AppTheme.green;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  Color _getResultColor() {
    switch (history.type) {
      case 'basic_calculator':
        return const Color(0xFF4CAF50);
      case 'compound_interest':
        return AppTheme.primary;
      default:
        return AppTheme.onSurface;
    }
  }

  String _getResultText() {
    switch (history.type) {
      case 'basic_calculator':
        final prev = history.inputs['previousValue'] ?? '';
        final op = history.inputs['operator'] ?? '';
        final current = history.inputs['currentValue'] ?? '';
        final result = history.results['result'] ?? '';
        return '$prev $op $current = $result';
      case 'compound_interest':
        final principal = history.inputs['principal'] ?? '';
        final finalAmount = history.results['finalAmount'] ?? '';
        final interest = history.results['interestEarned'] ?? '';
        return '₹$principal → ₹$finalAmount  (+$interest)';
      default:
        return history.results.toString();
    }
  }
}
