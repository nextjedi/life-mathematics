import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../utils/database_helper.dart';
import '../utils/finance.dart';
import '../utils/money.dart';
import '../widgets/finance_widgets.dart';

/// "What will this loan cost me every month?"
class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  static const List<Color> accent = [Color(0xFFFF9800), Color(0xFFE65100)];

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _resultKey = GlobalKey();

  _TenureUnit _unit = _TenureUnit.years;
  EmiResult? _result;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  int get _months {
    final raw = double.parse(_tenureController.text.replaceAll(',', ''));
    return _unit == _TenureUnit.years ? (raw * 12).round() : raw.round();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final result = calculateEmi(
      principal: double.parse(_amountController.text.replaceAll(',', '')),
      annualRatePercent: double.parse(_rateController.text),
      months: _months,
    );

    setState(() => _result = result);
    _saveToHistory(result);
    _revealResult();
  }

  void _revealResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  void _saveToHistory(EmiResult result) {
    final now = DateTime.now();
    context.read<HistoryProvider>().addHistory(
          CalculationHistory(
            type: 'emi',
            name: 'EMI Calculator',
            label: 'finance',
            isPinned: false,
            timestamp: now,
            inputs: {
              'principal': money(result.principal),
              'rate': '${_rateController.text}%',
              'months': result.months,
            },
            results: {
              'emi': money(result.emi),
              'totalInterest': money(result.totalInterest),
              'totalPayment': money(result.totalPayment),
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final result = _result;

    return FinanceScaffold(
      title: 'EMI Calculator',
      heroSubtitle: 'EMI = P·i·(1+i)ⁿ / ((1+i)ⁿ − 1)',
      icon: Icons.payments_outlined,
      accent: EmiCalculatorScreen.accent,
      formKey: _formKey,
      onCalculate: _calculate,
      fields: [
        MoneyField(
          controller: _amountController,
          label: 'Loan Amount',
          hint: '10,00,000',
          prefix: '₹',
        ),
        const SizedBox(height: 16),
        MoneyField(
          controller: _rateController,
          label: 'Interest Rate',
          hint: '9.0',
          suffix: '% p.a.',
          allowDecimal: true,
        ),
        const SizedBox(height: 16),
        SegmentedSelector<_TenureUnit>(
          label: 'Tenure in',
          options: const [
            (label: 'Years', value: _TenureUnit.years),
            (label: 'Months', value: _TenureUnit.months),
          ],
          selected: _unit,
          onChanged: (value) => setState(() => _unit = value),
        ),
        const SizedBox(height: 16),
        MoneyField(
          controller: _tenureController,
          label: 'Tenure',
          hint: _unit == _TenureUnit.years ? '5' : '60',
          suffix: _unit == _TenureUnit.years ? 'yrs' : 'mo',
          allowDecimal: _unit == _TenureUnit.years,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _calculate(),
          extraValidator: (value) {
            final months = _unit == _TenureUnit.years ? value * 12 : value;
            if (months < 1) return 'At least one month';
            if (months > 600) return 'Maximum 50 years';
            return null;
          },
        ),
      ],
      resultKey: _resultKey,
      results: result == null
          ? const []
          : [
              HeadlineResult(
                key: _resultKey,
                label: 'Monthly EMI',
                value: rupees(result.emi),
                stats: [
                  (
                    label: 'Principal',
                    value: rupees(result.principal),
                    color: palette.onSurfaceVariant,
                  ),
                  (
                    label: 'Total Interest',
                    value: rupees(result.totalInterest),
                    color: palette.error,
                  ),
                  (
                    label: 'Total Payable',
                    value: rupees(result.totalPayment),
                    color: palette.onSurface,
                  ),
                  (
                    label: 'Tenure',
                    value: formatMonths(result.months),
                    color: palette.onSurfaceVariant,
                  ),
                ],
                footnote:
                    'Interest is ${percent(result.interestShare, decimals: 1)} '
                    'of everything you repay',
              ),
              const SizedBox(height: 12),
              SplitBar(
                leftLabel: 'Principal ${rupees(result.principal)}',
                rightLabel: 'Interest ${rupees(result.totalInterest)}',
                leftFraction: 1 - result.interestShare,
                leftColor: palette.primary,
                rightColor: palette.error,
              ),
            ],
    );
  }
}

enum _TenureUnit { years, months }
