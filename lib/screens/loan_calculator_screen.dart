import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../utils/database_helper.dart';
import '../utils/finance.dart';
import '../utils/money.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/finance_widgets.dart';

/// "If I pay extra on top of my EMI, how much sooner is the loan over?"
class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  static const List<Color> accent = [Color(0xFF2196F3), Color(0xFF0D47A1)];

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();
  final _extraController = TextEditingController();
  final _resultKey = GlobalKey();

  ExtraPaymentFrequency _frequency = ExtraPaymentFrequency.yearly;
  LoanPayoffResult? _result;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final extraText = _extraController.text.replaceAll(',', '');
    final extra = extraText.isEmpty ? 0.0 : double.parse(extraText);

    try {
      final result = calculateLoanPayoff(
        principal: double.parse(_amountController.text.replaceAll(',', '')),
        annualRatePercent: double.parse(_rateController.text),
        months: (double.parse(_yearsController.text) * 12).round(),
        extraAmount: extra,
        frequency: _frequency,
      );
      setState(() => _result = result);
      _saveToHistory(result);
      _revealResult();
    } on LoanNeverAmortisesError catch (e) {
      setState(() => _result = null);
      showAppSnackBar(context, e.message);
    }
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

  void _saveToHistory(LoanPayoffResult result) {
    final now = DateTime.now();
    context.read<HistoryProvider>().addHistory(
          CalculationHistory(
            type: 'loan_payoff',
            name: 'Loan Payoff',
            label: 'finance',
            isPinned: false,
            timestamp: now,
            inputs: {
              'principal': money(result.principal),
              'rate': '${_rateController.text}%',
              'months': result.baselineMonths,
              'extra': money(result.totalExtraPaid),
              'frequency': _frequency.name,
            },
            results: {
              'emi': money(result.emi),
              'payoff': formatMonths(result.payoffMonths),
              'monthsSaved': result.monthsSaved,
              'interestSaved': money(result.interestSaved),
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return FinanceScaffold(
      title: 'Loan Payoff',
      heroSubtitle: 'Pay extra, finish early',
      icon: Icons.account_balance_outlined,
      accent: LoanCalculatorScreen.accent,
      formKey: _formKey,
      onCalculate: _calculate,
      ctaLabel: 'See payoff',
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
        MoneyField(
          controller: _yearsController,
          label: 'Original Tenure',
          hint: '20',
          suffix: 'yrs',
          allowDecimal: true,
          extraValidator: (value) =>
              value > 50 ? 'Maximum 50 years' : null,
        ),
        const SizedBox(height: 16),
        SegmentedSelector<ExtraPaymentFrequency>(
          label: 'Extra payment',
          options: const [
            (label: 'Every year', value: ExtraPaymentFrequency.yearly),
            (label: 'Every month', value: ExtraPaymentFrequency.monthly),
          ],
          selected: _frequency,
          onChanged: (value) => setState(() => _frequency = value),
        ),
        const SizedBox(height: 16),
        OptionalMoneyField(
          controller: _extraController,
          label: _frequency == ExtraPaymentFrequency.yearly
              ? 'Extra paid each year'
              : 'Extra paid each month',
          hint: 'Leave blank for none',
          prefix: '₹',
        ),
      ],
      resultKey: _resultKey,
      results: result == null ? const [] : _results(context, result),
    );
  }

  List<Widget> _results(BuildContext context, LoanPayoffResult result) {
    final palette = context.palette;

    return [
      HeadlineResult(
        key: _resultKey,
        label: result.hasExtra ? 'Loan clears in' : 'Loan runs for',
        value: formatMonths(result.payoffMonths),
        valueColor: result.hasExtra ? palette.green : palette.primary,
        stats: [
          (
            label: 'Monthly EMI',
            value: rupees(result.emi),
            color: palette.onSurface,
          ),
          (
            label: 'Interest paid',
            value: rupees(result.actualInterest),
            color: palette.error,
          ),
          if (result.hasExtra) ...[
            (
              label: 'Time saved',
              value: formatMonths(result.monthsSaved),
              color: palette.green,
            ),
            (
              label: 'Interest saved',
              value: rupees(result.interestSaved),
              color: palette.green,
            ),
          ] else ...[
            (
              label: 'Total repaid',
              value: rupees(result.principal + result.actualInterest),
              color: palette.onSurfaceVariant,
            ),
            (
              label: 'Original tenure',
              value: formatMonths(result.baselineMonths),
              color: palette.onSurfaceVariant,
            ),
          ],
        ],
        footnote: result.hasExtra
            ? 'Paying ${rupees(result.totalExtraPaid)} extra in total clears '
                'the loan ${formatMonths(result.monthsSaved)} early'
            : 'Add an extra payment above to see how much sooner it ends',
      ),
      if (result.hasExtra) ...[
        const SizedBox(height: 12),
        SplitBar(
          leftLabel: 'Paid ${formatMonths(result.payoffMonths)}',
          rightLabel: 'Saved ${formatMonths(result.monthsSaved)}',
          leftFraction: result.payoffMonths / result.baselineMonths,
          leftColor: palette.primary,
          rightColor: palette.green,
        ),
      ],
      const SizedBox(height: 12),
      BreakdownTable(
        title: 'Year-by-Year Balance',
        columns: const [
          (label: 'Yr', flex: 1),
          (label: 'Principal', flex: 2),
          (label: 'Interest', flex: 2),
          (label: 'Balance', flex: 2),
        ],
        rows: [
          for (final row in result.schedule)
            [
              '${row.year}',
              moneyWhole(row.principalPaid + row.extraPaid),
              moneyWhole(row.interestPaid),
              moneyWhole(row.closingBalance),
            ],
        ],
        accentColumn: 2,
        accentColor: palette.error,
        footnote: result.hasExtra
            ? 'Principal column includes the extra payments.'
            : null,
      ),
    ];
  }
}
