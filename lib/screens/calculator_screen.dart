import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
import '../providers/shell_provider.dart';
import '../utils/calculator_logic.dart';
import '../utils/database_helper.dart';
import '../widgets/calculator_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorLogic _calculator = CalculatorLogic();
  bool _showFullDecimal = false;
  ShellProvider? _shell;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shell = context.read<ShellProvider>();
    if (identical(shell, _shell)) return;
    _shell?.removeListener(_onShellChanged);
    _shell = shell..addListener(_onShellChanged);
  }

  @override
  void dispose() {
    _shell?.removeListener(_onShellChanged);
    super.dispose();
  }

  /// History can hand a previous calculation back to the calculator.
  void _onShellChanged() {
    final pending = _shell?.takePending();
    if (pending == null || !mounted) return;
    setState(() {
      _showFullDecimal = false;
      _calculator.restore(pending.value, expression: pending.expression);
    });
  }

  /// Records the calculation that just completed. Called *after* [
  /// CalculatorLogic.calculate], so the result actually exists — previously
  /// this ran first and every entry was saved with an empty result.
  void _saveCalculation() {
    final done = _calculator.lastCalculation;
    if (done == null) return; // nothing evaluated, or it errored

    final now = DateTime.now();
    final history = CalculationHistory(
      type: 'basic_calculator',
      name: 'Basic Calculator',
      label: 'arithmetic',
      isPinned: false,
      timestamp: now,
      inputs: {'expression': done.expression},
      results: {'result': done.result},
    );

    context.read<HistoryProvider>().addHistory(history);
  }

  void _onButtonPressed(String value) {
    setState(() {
      _showFullDecimal = false;
      switch (value) {
        case 'C':
          _calculator.clear();
          break;
        case 'CE':
          _calculator.clearEntry();
          break;
        case '⌫':
          _calculator.backspace();
          break;
        case '+':
        case '−':
        case '×':
        case '÷':
          _calculator.inputOperator(value);
          break;
        case '=':
          _calculator.calculate();
          break;
        case '.':
          _calculator.inputDecimal();
          break;
        case '±':
          _calculator.toggleSign();
          break;
        default:
          if (value.isNotEmpty && '0123456789'.contains(value)) {
            _calculator.inputNumber(value);
          }
      }
    });

    // Persisting touches a provider, so keep it outside setState.
    if (value == '=') _saveCalculation();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          // ── Display zone ────────────────────────────────────────────────
          Expanded(
            flex: 38,
            child: Container(
              width: double.infinity,
              color: palette.background,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: _Display(
                calculator: _calculator,
                showFullDecimal: _showFullDecimal,
                onToggleFullDecimal: () =>
                    setState(() => _showFullDecimal = !_showFullDecimal),
              ),
            ),
          ),

          // ── Keypad zone ─────────────────────────────────────────────────
          Expanded(
            flex: 62,
            child: Container(
              color: palette.surfaceContainerLow,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  _row(
                    const ['C', 'CE', '⌫', '÷'],
                    const [
                      ButtonType.clear,
                      ButtonType.function,
                      ButtonType.function,
                      ButtonType.operator,
                    ],
                    const ['Clear all', 'Clear entry', 'Backspace', 'Divide'],
                  ),
                  const SizedBox(height: 10),
                  _row(
                    const ['7', '8', '9', '×'],
                    const [
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.operator,
                    ],
                    const ['7', '8', '9', 'Multiply'],
                  ),
                  const SizedBox(height: 10),
                  _row(
                    const ['4', '5', '6', '−'],
                    const [
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.operator,
                    ],
                    const ['4', '5', '6', 'Subtract'],
                  ),
                  const SizedBox(height: 10),
                  _row(
                    const ['1', '2', '3', '+'],
                    const [
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.operator,
                    ],
                    const ['1', '2', '3', 'Add'],
                  ),
                  const SizedBox(height: 10),
                  _row(
                    const ['±', '0', '.', '='],
                    const [
                      ButtonType.function,
                      ButtonType.number,
                      ButtonType.number,
                      ButtonType.equal,
                    ],
                    const ['Toggle sign', '0', 'Decimal point', 'Equals'],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    List<String> labels,
    List<ButtonType> types,
    List<String> semantics,
  ) {
    return Expanded(
      child: Row(
        children: List.generate(labels.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
              child: CalculatorButton(
                text: labels[i],
                type: types[i],
                semanticLabel: semantics[i],
                onPressed: () => _onButtonPressed(labels[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// The expression + result readout.
///
/// Both lines are [Flexible] so that in landscape — where the display zone is
/// only ~90dp tall — the text scales down instead of overflowing.
class _Display extends StatelessWidget {
  final CalculatorLogic calculator;
  final bool showFullDecimal;
  final VoidCallback onToggleFullDecimal;

  const _Display({
    required this.calculator,
    required this.showFullDecimal,
    required this.onToggleFullDecimal,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final expression = calculator.expression;
    final resultColor =
        calculator.hasError ? palette.error : palette.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Running tape of every step since the last C. Chained arithmetic
        // collapses to a single running total, so this is the only place the
        // earlier steps of a long calculation stay visible.
        if (calculator.tape.isNotEmpty)
          Expanded(
            flex: 3,
            child: _Tape(text: calculator.tape),
          ),
        if (expression.isNotEmpty)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                expression,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  color: palette.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Flexible(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (calculator.isResultTruncated)
                _PrecisionToggle(
                  expanded: showFullDecimal,
                  onTap: onToggleFullDecimal,
                ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    showFullDecimal
                        ? calculator.fullResult
                        : calculator.displayValue,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: resultColor,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The running tape of completed steps.
///
/// `reverse: true` anchors the content to the bottom, so a short tape sits
/// just above the expression line and a long one keeps the newest step in
/// view while still letting the user scroll back through the whole chain.
class _Tape extends StatelessWidget {
  final String text;

  const _Tape({required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: 'Calculation tape',
      value: text,
      child: SingleChildScrollView(
        reverse: true,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: palette.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Expands a rounded result to full precision. Sits next to the number with a
/// 48dp tap target and a tinted chip, rather than a bare 22px glyph stranded
/// at the far edge of the screen.
class _PrecisionToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _PrecisionToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: expanded ? 'Show rounded result' : 'Show full precision',
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: palette.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                expanded ? Icons.unfold_less : Icons.unfold_more,
                size: 22,
                color: palette.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
