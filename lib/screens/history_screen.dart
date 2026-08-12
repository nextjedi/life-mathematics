import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../providers/shell_provider.dart';
import '../utils/database_helper.dart';
import '../utils/finance.dart' show formatMonths;
import '../utils/money.dart' show years;
import '../widgets/app_snackbar.dart';

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
      if (mounted) context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: palette.primary),
          );
        }

        if (provider.error != null) {
          return _ErrorState(
            message: provider.error!,
            onRetry: provider.loadHistory,
          );
        }

        if (provider.history.isEmpty) {
          return const _EmptyState();
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
                    provider.history.length == 1
                        ? '1 calculation'
                        : '${provider.history.length} calculations',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: palette.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showClearDialog(context, provider),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: palette.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: provider.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = provider.history[index];
                  return _HistoryCard(
                    history: item,
                    onDelete: () => provider.deleteHistory(item.id!),
                    onPin: () => provider.togglePin(item.id!, !item.isPinned),
                    onTap: () => _restore(context, item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Sends a stored calculation back to the calculator so it can be reused,
  /// carrying the working with it rather than just the answer.
  void _restore(BuildContext context, CalculationHistory item) {
    final restorable = _restorable(item);
    if (restorable == null) {
      showAppSnackBar(context, 'Nothing to load from this entry');
      return;
    }
    context.read<ShellProvider>().restoreToCalculator(
          restorable.value,
          expression: restorable.expression,
        );
    showAppSnackBar(context, 'Loaded ${restorable.value} into the calculator');
  }

  static RestoredCalculation? _restorable(CalculationHistory item) {
    // The single number worth sending back to the calculator, per type.
    final raw = item.results['result'] ??
        item.results['finalAmount'] ??
        item.results['emi'] ??
        item.results['maturity'] ??
        item.results['interestSaved'];
    if (raw == null) return null;
    // Stored money values carry grouping separators; the calculator wants a
    // bare number it can parse.
    final cleaned = raw.toString().replaceAll(',', '');
    if (double.tryParse(cleaned) == null) return null;
    return (value: cleaned, expression: _restorableExpression(item));
  }

  /// The working behind a stored result, shown on the calculator's tape.
  static String? _restorableExpression(CalculationHistory item) {
    switch (item.type) {
      case 'basic_calculator':
        final expression = item.inputs['expression'];
        if (expression != null && '$expression'.isNotEmpty) {
          return '$expression';
        }
        // Rows written before the schema change kept the operands apart.
        final legacy = [
          item.inputs['previousValue'],
          item.inputs['operator'],
          item.inputs['currentValue'],
        ].where((e) => e != null && '$e'.isNotEmpty).join(' ');
        return legacy.isEmpty ? null : legacy;
      case 'compound_interest':
        final principal = item.inputs['principal'];
        final rate = item.inputs['rate'];
        final term = item.inputs['years'];
        if (principal == null || rate == null || term == null) return null;
        return '₹$principal @ $rate for ${years(term)} yr';
      case 'emi':
        final principal = item.inputs['principal'];
        final rate = item.inputs['rate'];
        final months = item.inputs['months'];
        if (principal == null || rate == null || months == null) return null;
        return 'EMI on ₹$principal @ $rate over '
            '${formatMonths(int.tryParse('$months') ?? 0)}';
      case 'loan_payoff':
        final principal = item.inputs['principal'];
        final payoff = item.results['payoff'];
        if (principal == null || payoff == null) return null;
        return 'Interest saved on ₹$principal, cleared in $payoff';
      case 'investment_sip':
        final monthly = item.inputs['monthly'];
        final rate = item.inputs['rate'];
        final years = item.inputs['years'];
        if (monthly == null || rate == null || years == null) return null;
        return 'SIP ₹$monthly/mo @ $rate for $years yr';
      default:
        return null;
    }
  }


  void _showClearDialog(BuildContext context, HistoryProvider provider) {
    final palette = context.palette;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Clear History',
          style: GoogleFonts.spaceGrotesk(
            color: palette.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently delete all calculation history.',
          style: GoogleFonts.manrope(color: palette.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(color: palette.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: GoogleFonts.manrope(
                color: palette.error,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    final palette = context.palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_outlined,
                size: 32, color: palette.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start calculating to see your history here',
            style: GoogleFonts.manrope(
                fontSize: 13, color: palette.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: palette.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 32, color: palette.error),
            ),
            const SizedBox(height: 16),
            Text(
              'History unavailable',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: palette.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13, color: palette.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: GoogleFonts.manrope(
                  color: palette.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CalculationHistory history;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.history,
    required this.onDelete,
    required this.onPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final resultText = _getResultText();
    final resultColor = _getResultColor(palette);
    final avatarColor = _getAvatarColor(palette);

    return Material(
      color: history.isPinned
          ? palette.primary.withValues(alpha: 0.08)
          : palette.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Pinned rows get a visible accent border — the old treatment
            // shifted the background by two shades of near-black, which read
            // as no change at all.
            border: history.isPinned
                ? Border.all(color: palette.primary.withValues(alpha: 0.55))
                : null,
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getAvatarLabel(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: avatarColor,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            history.name,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: palette.onSurfaceVariant,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd · HH:mm').format(history.timestamp),
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color:
                                palette.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resultText,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: resultColor,
                      ),
                      // Compound-interest rows are long; two lines beats
                      // truncating the answer mid-number.
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconAction(
                    icon: history.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: history.isPinned
                        ? palette.pinned
                        : palette.onSurfaceVariant,
                    tooltip: history.isPinned ? 'Unpin' : 'Pin',
                    onTap: onPin,
                  ),
                  _IconAction(
                    icon: Icons.delete_outline_rounded,
                    color: palette.onSurfaceVariant,
                    tooltip: 'Delete',
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAvatarLabel() {
    switch (history.type) {
      case 'basic_calculator':
        return '=';
      case 'compound_interest':
        return '%';
      case 'emi':
        return '₹/m';
      case 'loan_payoff':
        return '⏱';
      case 'investment_sip':
        return 'SIP';
      case 'investment_roi':
        return '↗';
      default:
        return '?';
    }
  }

  Color _getAvatarColor(AppPalette palette) {
    switch (history.type) {
      case 'basic_calculator':
        return palette.primary;
      case 'compound_interest':
      case 'loan_payoff':
      case 'investment_sip':
      case 'investment_roi':
        return palette.green;
      case 'emi':
        return const Color(0xFFFF9800);
      default:
        return palette.onSurfaceVariant;
    }
  }

  Color _getResultColor(AppPalette palette) {
    switch (history.type) {
      case 'basic_calculator':
        return palette.green;
      case 'compound_interest':
      case 'emi':
      case 'loan_payoff':
      case 'investment_sip':
      case 'investment_roi':
        return palette.primary;
      default:
        return palette.onSurface;
    }
  }

  String _getResultText() {
    switch (history.type) {
      case 'basic_calculator':
        final result = history.results['result'];
        // Rows written before the schema change stored the operands
        // separately and never stored a result.
        final expression = history.inputs['expression'] ??
            [
              history.inputs['previousValue'],
              history.inputs['operator'],
              history.inputs['currentValue'],
            ].where((e) => e != null && '$e'.isNotEmpty).join(' ');
        if (result == null || '$result'.isEmpty) return '$expression = ?';
        return '$expression = $result';
      case 'compound_interest':
        final principal = history.inputs['principal'] ?? '';
        final finalAmount = history.results['finalAmount'] ?? '';
        final interest = history.results['interestEarned'] ?? '';
        return '₹$principal → ₹$finalAmount  (+$interest)';
      case 'emi':
        final emi = history.results['emi'] ?? '';
        final principal = history.inputs['principal'] ?? '';
        final interest = history.results['totalInterest'] ?? '';
        return '₹$principal → ₹$emi/mo  (interest ₹$interest)';
      case 'loan_payoff':
        final payoff = history.results['payoff'] ?? '';
        final saved = history.results['interestSaved'] ?? '';
        final emi = history.results['emi'] ?? '';
        final monthsSaved = history.results['monthsSaved'];
        if (monthsSaved is int && monthsSaved > 0) {
          return 'Clears in $payoff · saves ₹$saved';
        }
        return 'Runs $payoff at ₹$emi/mo';
      case 'investment_sip':
        final monthly = history.inputs['monthly'] ?? '';
        final maturity = history.results['maturity'] ?? '';
        final gain = history.results['gain'] ?? '';
        return '₹$monthly/mo → ₹$maturity  (+₹$gain)';
      case 'investment_roi':
        final cagr = history.results['cagr'] ?? '';
        final absolute = history.results['absoluteReturn'] ?? '';
        final invested = history.inputs['invested'] ?? '';
        final current = history.inputs['currentValue'] ?? '';
        return '₹$invested → ₹$current  ($cagr CAGR, $absolute)';
      default:
        return history.results.toString();
    }
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
