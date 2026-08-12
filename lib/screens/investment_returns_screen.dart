import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../utils/database_helper.dart';
import '../utils/finance.dart';
import '../utils/money.dart';
import '../widgets/finance_widgets.dart';

/// Two questions in one screen: what a monthly SIP will grow into, and what a
/// holding you already own has actually returned.
class InvestmentReturnsScreen extends StatefulWidget {
  const InvestmentReturnsScreen({super.key});

  static const List<Color> accent = [Color(0xFF9C27B0), Color(0xFF4A148C)];

  @override
  State<InvestmentReturnsScreen> createState() =>
      _InvestmentReturnsScreenState();
}

enum _Mode { sip, realised }

class _InvestmentReturnsScreenState extends State<InvestmentReturnsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultKey = GlobalKey();

  // SIP
  final _monthlyController = TextEditingController();
  final _rateController = TextEditingController();
  final _sipYearsController = TextEditingController();

  // Realised return
  final _investedController = TextEditingController();
  final _currentController = TextEditingController();
  final _heldYearsController = TextEditingController();

  _Mode _mode = _Mode.sip;
  SipResult? _sip;
  RoiResult? _roi;

  @override
  void dispose() {
    _monthlyController.dispose();
    _rateController.dispose();
    _sipYearsController.dispose();
    _investedController.dispose();
    _currentController.dispose();
    _heldYearsController.dispose();
    super.dispose();
  }

  void _setMode(_Mode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      // Results from the other mode would be stale and confusing.
      _sip = null;
      _roi = null;
    });
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_mode == _Mode.sip) {
      final result = calculateSip(
        monthly: double.parse(_monthlyController.text.replaceAll(',', '')),
        annualRatePercent: double.parse(_rateController.text),
        years: double.parse(_sipYearsController.text),
      );
      setState(() {
        _sip = result;
        _roi = null;
      });
      _saveSip(result);
    } else {
      final result = calculateRoi(
        invested: double.parse(_investedController.text.replaceAll(',', '')),
        currentValue: double.parse(_currentController.text.replaceAll(',', '')),
        years: double.parse(_heldYearsController.text),
      );
      setState(() {
        _roi = result;
        _sip = null;
      });
      _saveRoi(result);
    }
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

  void _saveSip(SipResult result) {
    context.read<HistoryProvider>().addHistory(
          CalculationHistory(
            type: 'investment_sip',
            name: 'SIP Projection',
            label: 'finance',
            isPinned: false,
            timestamp: DateTime.now(),
            inputs: {
              'monthly': money(result.monthly),
              'rate': '${_rateController.text}%',
              'years': _sipYearsController.text,
            },
            results: {
              'maturity': money(result.maturity),
              'invested': money(result.invested),
              'gain': money(result.gain),
            },
          ),
        );
  }

  void _saveRoi(RoiResult result) {
    context.read<HistoryProvider>().addHistory(
          CalculationHistory(
            type: 'investment_roi',
            name: 'Investment Return',
            label: 'finance',
            isPinned: false,
            timestamp: DateTime.now(),
            inputs: {
              'invested': money(result.invested),
              'currentValue': money(result.currentValue),
              'years': _heldYearsController.text,
            },
            results: {
              'cagr': percent(result.cagr),
              'absoluteReturn': signedPercent(result.absoluteReturn),
              'profit': money(result.profit),
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FinanceScaffold(
      title: 'Investment Returns',
      heroSubtitle: _mode == _Mode.sip
          ? 'What a monthly SIP grows into'
          : 'What a holding has actually returned',
      icon: Icons.show_chart_rounded,
      accent: InvestmentReturnsScreen.accent,
      formKey: _formKey,
      onCalculate: _calculate,
      ctaLabel: _mode == _Mode.sip ? 'Project' : 'Calculate',
      fields: [
        SegmentedSelector<_Mode>(
          options: const [
            (label: 'SIP', value: _Mode.sip),
            (label: 'Returns', value: _Mode.realised),
          ],
          selected: _mode,
          onChanged: _setMode,
        ),
        const SizedBox(height: 16),
        if (_mode == _Mode.sip) ..._sipFields() else ..._roiFields(),
      ],
      resultKey: _resultKey,
      results: _results(context),
    );
  }

  List<Widget> _sipFields() => [
        MoneyField(
          key: const ValueKey('sip-monthly'),
          controller: _monthlyController,
          label: 'Monthly Investment',
          hint: '10,000',
          prefix: '₹',
        ),
        const SizedBox(height: 16),
        MoneyField(
          key: const ValueKey('sip-rate'),
          controller: _rateController,
          label: 'Expected Return',
          hint: '12.0',
          suffix: '% p.a.',
          allowDecimal: true,
        ),
        const SizedBox(height: 16),
        MoneyField(
          key: const ValueKey('sip-years'),
          controller: _sipYearsController,
          label: 'Duration',
          hint: '10',
          suffix: 'yrs',
          allowDecimal: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _calculate(),
          extraValidator: (value) => value > 50 ? 'Maximum 50 years' : null,
        ),
      ];

  List<Widget> _roiFields() => [
        MoneyField(
          key: const ValueKey('roi-invested'),
          controller: _investedController,
          label: 'Amount Invested',
          hint: '1,00,000',
          prefix: '₹',
        ),
        const SizedBox(height: 16),
        MoneyField(
          key: const ValueKey('roi-current'),
          controller: _currentController,
          label: 'Value Today',
          hint: '2,50,000',
          prefix: '₹',
          allowDecimal: true,
        ),
        const SizedBox(height: 16),
        MoneyField(
          key: const ValueKey('roi-years'),
          controller: _heldYearsController,
          label: 'Held For',
          hint: '5',
          suffix: 'yrs',
          allowDecimal: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _calculate(),
          extraValidator: (value) => value > 100 ? 'Maximum 100 years' : null,
        ),
      ];

  List<Widget> _results(BuildContext context) {
    final palette = context.palette;

    final sip = _sip;
    if (sip != null) {
      return [
        HeadlineResult(
          key: _resultKey,
          label: 'Maturity Value',
          value: rupees(sip.maturity),
          stats: [
            (
              label: 'Invested',
              value: rupees(sip.invested),
              color: palette.onSurfaceVariant,
            ),
            (
              label: 'Gain',
              value: '${rupees(sip.gain)} (${signedPercent(sip.gainRatio)})',
              color: palette.green,
            ),
          ],
          footnote: '${formatMonths(sip.months)} of monthly contributions',
        ),
        const SizedBox(height: 12),
        SplitBar(
          leftLabel: 'Invested ${rupees(sip.invested)}',
          rightLabel: 'Gain ${rupees(sip.gain)}',
          leftFraction:
              sip.maturity == 0 ? 1 : sip.invested / sip.maturity,
          leftColor: palette.primary,
          rightColor: palette.green,
        ),
        const SizedBox(height: 12),
        BreakdownTable(
          title: 'Year-by-Year Growth',
          columns: const [
            (label: 'Yr', flex: 1),
            (label: 'Invested', flex: 2),
            (label: 'Value', flex: 2),
            (label: 'Gain', flex: 2),
          ],
          rows: [
            for (final row in sip.schedule)
              [
                '${row.year}',
                moneyWhole(row.invested),
                moneyWhole(row.value),
                moneyWhole(row.gain),
              ],
          ],
          accentColumn: 3,
          accentColor: palette.green,
        ),
      ];
    }

    final roi = _roi;
    if (roi != null) {
      final tone = roi.isLoss ? palette.error : palette.green;
      return [
        HeadlineResult(
          key: _resultKey,
          label: 'Annualised Return (CAGR)',
          value: signedPercent(roi.cagr, decimals: 2),
          valueColor: tone,
          stats: [
            (
              label: 'Invested',
              value: rupees(roi.invested),
              color: palette.onSurfaceVariant,
            ),
            (
              label: 'Value today',
              value: rupees(roi.currentValue),
              color: palette.onSurface,
            ),
            (
              label: roi.isLoss ? 'Loss' : 'Profit',
              value: rupees(roi.profit.abs()),
              color: tone,
            ),
            (
              label: 'Total return',
              value: signedPercent(roi.absoluteReturn),
              color: tone,
            ),
          ],
          footnote: roi.isLoss
              ? 'Down ${signedPercent(roi.absoluteReturn)} '
                  'over ${years(roi.years)} yr'
              : 'Grew ${(roi.currentValue / roi.invested).toStringAsFixed(2)}× '
                  'over ${years(roi.years)} yr',
        ),
      ];
    }

    return const [];
  }
}
