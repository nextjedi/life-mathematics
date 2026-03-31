import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../utils/database_helper.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() =>
      _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();

  int _compoundingFrequency = 12;
  _CompoundResult? _result;

  static const List<({String label, int value})> _frequencies = [
    (label: 'Annual', value: 1),
    (label: 'Semi', value: 2),
    (label: 'Quarterly', value: 4),
    (label: 'Monthly', value: 12),
    (label: 'Daily', value: 365),
  ];

  final _currencyFormat = NumberFormat('#,##0.00');

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final p = double.parse(_principalController.text.replaceAll(',', ''));
    final r = double.parse(_rateController.text) / 100;
    final n = _compoundingFrequency.toDouble();
    final t = double.parse(_yearsController.text);

    final finalAmount = (p * pow(1 + r / n, n * t)).toDouble();
    final interestEarned = finalAmount - p;
    final effectiveAnnualRate = ((pow(1 + r / n, n) - 1) * 100).toDouble();

    final years = t.ceil();
    final List<_YearRow> breakdown = [];
    for (int y = 1; y <= years; y++) {
      final tYear = y < years ? y.toDouble() : t;
      final balance = (p * pow(1 + r / n, n * tYear)).toDouble();
      final prevBalance =
          y == 1 ? p : (p * pow(1 + r / n, n * (tYear - 1))).toDouble();
      breakdown.add(_YearRow(
        year: y,
        isPartial: y == years && t != t.floorToDouble(),
        balance: balance,
        interestThisYear: balance - prevBalance,
      ));
    }

    setState(() {
      _result = _CompoundResult(
        principal: p,
        finalAmount: finalAmount,
        interestEarned: interestEarned,
        effectiveAnnualRate: effectiveAnnualRate,
        breakdown: breakdown,
      );
    });

    _saveToHistory(p, r * 100, _compoundingFrequency, t, finalAmount,
        interestEarned);
  }

  void _saveToHistory(double principal, double rate, int freq, double years,
      double finalAmount, double interestEarned) {
    final now = DateTime.now();
    final history = CalculationHistory(
      type: 'compound_interest',
      name: 'Compound Interest ${DateFormat('MMM dd, HH:mm').format(now)}',
      label: 'finance',
      isPinned: false,
      timestamp: now,
      inputs: {
        'principal': _currencyFormat.format(principal),
        'rate': '$rate%',
        'frequency': freq,
        'years': years,
      },
      results: {
        'finalAmount': _currencyFormat.format(finalAmount),
        'interestEarned': _currencyFormat.format(interestEarned),
      },
    );
    Provider.of<HistoryProvider>(context, listen: false).addHistory(history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Compound Interest',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero header ───────────────────────────────────────────────
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_up_rounded,
                          color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Compound Interest',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A = P(1 + r/n)ⁿᵗ',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Input card ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildField(
                      controller: _principalController,
                      label: 'Principal Amount',
                      hint: '10,000',
                      prefix: '₹',
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _rateController,
                      label: 'Annual Rate',
                      hint: '8.0',
                      suffix: '%',
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    _FrequencySelector(
                      frequencies: _frequencies,
                      selected: _compoundingFrequency,
                      onChanged: (v) =>
                          setState(() => _compoundingFrequency = v),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _yearsController,
                      label: 'Time Period',
                      hint: '5',
                      suffix: 'yrs',
                      allowDecimal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Calculate button ──────────────────────────────────────────
              GestureDetector(
                onTap: _calculate,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF069E46)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Calculate  →',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Results ───────────────────────────────────────────────────
              if (_result != null) ...[
                const SizedBox(height: 20),
                _ResultCard(
                    result: _result!, currencyFormat: _currencyFormat),
                const SizedBox(height: 12),
                _BreakdownCard(
                    breakdown: _result!.breakdown,
                    currencyFormat: _currencyFormat),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
    bool allowDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(allowDecimal ? r'[\d.]' : r'\d')),
      ],
      style: GoogleFonts.spaceGrotesk(
          color: AppTheme.onSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix != null ? '$prefix  ' : null,
        suffixText: suffix,
        prefixStyle: GoogleFonts.manrope(
            color: AppTheme.onSurfaceVariant, fontSize: 15),
        suffixStyle: GoogleFonts.manrope(
            color: AppTheme.onSurfaceVariant, fontSize: 13),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        final val = double.tryParse(v.replaceAll(',', ''));
        if (val == null || val <= 0) return 'Enter a valid positive number';
        return null;
      },
    );
  }
}

// ── Frequency selector ────────────────────────────────────────────────────────
class _FrequencySelector extends StatelessWidget {
  final List<({String label, int value})> frequencies;
  final int selected;
  final ValueChanged<int> onChanged;

  const _FrequencySelector({
    required this.frequencies,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compounding',
          style: GoogleFonts.manrope(
              fontSize: 12, color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: frequencies.map((f) {
              final isActive = f.value == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(f.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDim],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        f.label,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? Colors.white
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────
class _CompoundResult {
  final double principal;
  final double finalAmount;
  final double interestEarned;
  final double effectiveAnnualRate;
  final List<_YearRow> breakdown;

  const _CompoundResult({
    required this.principal,
    required this.finalAmount,
    required this.interestEarned,
    required this.effectiveAnnualRate,
    required this.breakdown,
  });
}

class _YearRow {
  final int year;
  final bool isPartial;
  final double balance;
  final double interestThisYear;

  const _YearRow({
    required this.year,
    required this.isPartial,
    required this.balance,
    required this.interestThisYear,
  });
}

class _ResultCard extends StatelessWidget {
  final _CompoundResult result;
  final NumberFormat currencyFormat;

  const _ResultCard({required this.result, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final interestPercent =
        (result.interestEarned / result.principal * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13121F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final Amount',
            style: GoogleFonts.manrope(
                fontSize: 12, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '₹ ${currencyFormat.format(result.finalAmount)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Chip(
                  label: 'Principal',
                  value: '₹ ${currencyFormat.format(result.principal)}',
                  color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 8),
              _Chip(
                  label: 'Interest',
                  value:
                      '₹ ${currencyFormat.format(result.interestEarned)} (+$interestPercent%)',
                  color: AppTheme.green),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Effective Annual Rate: ${result.effectiveAnnualRate.toStringAsFixed(2)}%',
              style: GoogleFonts.manrope(
                  fontSize: 12, color: AppTheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Chip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 10, color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Breakdown table ───────────────────────────────────────────────────────────
class _BreakdownCard extends StatelessWidget {
  final List<_YearRow> breakdown;
  final NumberFormat currencyFormat;

  const _BreakdownCard(
      {required this.breakdown, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Year-by-Year Breakdown',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              _cell('Year', flex: 1, isHeader: true),
              _cell('Balance', flex: 2, isHeader: true),
              _cell('Interest', flex: 2, isHeader: true),
            ],
          ),
          const SizedBox(height: 8),
          ...breakdown.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    _cell(
                        row.isPartial ? '${row.year}*' : '${row.year}',
                        flex: 1),
                    _cell('₹ ${currencyFormat.format(row.balance)}',
                        flex: 2),
                    _cell(
                        '₹ ${currencyFormat.format(row.interestThisYear)}',
                        flex: 2,
                        color: AppTheme.green),
                  ],
                ),
              )),
          if (breakdown.any((r) => r.isPartial))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '* Partial year',
                style: GoogleFonts.manrope(
                    fontSize: 11, color: AppTheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(String text,
      {required int flex, bool isHeader = false, Color? color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: isHeader ? 12 : 13,
          fontWeight:
              isHeader ? FontWeight.w700 : FontWeight.w400,
          color: color ??
              (isHeader ? AppTheme.onSurfaceVariant : AppTheme.onSurface),
        ),
      ),
    );
  }
}
