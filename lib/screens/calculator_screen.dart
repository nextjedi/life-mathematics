import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/history_provider.dart';
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

  void _saveCalculation() {
    final prev = _calculator.previousValue;
    final op = _calculator.currentOperator;
    final current = _calculator.displayValue;
    if (prev.isEmpty || op.isEmpty) return;

    final now = DateTime.now();
    final history = CalculationHistory(
      type: 'basic_calculator',
      name: 'Basic Calc ${DateFormat('MMM dd, HH:mm').format(now)}',
      label: 'arithmetic',
      isPinned: false,
      timestamp: now,
      inputs: {
        'previousValue': prev,
        'operator': op,
        'currentValue': current,
      },
      results: {},
    );

    Provider.of<HistoryProvider>(context, listen: false).addHistory(history);
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
          _saveCalculation();
          _calculator.calculate();
          break;
        case '.':
          _calculator.inputDecimal();
          break;
        case '±':
          _calculator.toggleSign();
          break;
        case '%':
          _calculator.percentage();
          break;
        default:
          if (value.isNotEmpty && '0123456789'.contains(value)) {
            _calculator.inputNumber(value);
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Display zone (#0e0e0e) ──────────────────────────────────────────
        Expanded(
          flex: 38,
          child: Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression line
                if (_calculator.expression.isNotEmpty)
                  Text(
                    _calculator.expression,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                const SizedBox(height: 4),
                // Main result
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_calculator.isResultTruncated)
                      GestureDetector(
                        onTap: () => setState(
                            () => _showFullDecimal = !_showFullDecimal),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            _showFullDecimal
                                ? Icons.unfold_less
                                : Icons.unfold_more,
                            size: 22,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _showFullDecimal
                              ? _calculator.fullResult
                              : _calculator.displayValue,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.onSurface,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Keypad zone (#131313) ───────────────────────────────────────────
        Expanded(
          flex: 62,
          child: Container(
            color: AppTheme.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              children: [
                _row(['C', 'CE', '⌫', '÷'],
                    [ButtonType.clear, ButtonType.function, ButtonType.function, ButtonType.operator]),
                const SizedBox(height: 10),
                _row(['7', '8', '9', '×'],
                    [ButtonType.number, ButtonType.number, ButtonType.number, ButtonType.operator]),
                const SizedBox(height: 10),
                _row(['4', '5', '6', '−'],
                    [ButtonType.number, ButtonType.number, ButtonType.number, ButtonType.operator]),
                const SizedBox(height: 10),
                _row(['1', '2', '3', '+'],
                    [ButtonType.number, ButtonType.number, ButtonType.number, ButtonType.operator]),
                const SizedBox(height: 10),
                _row(['±', '0', '.', '='],
                    [ButtonType.function, ButtonType.number, ButtonType.number, ButtonType.equal]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(List<String> labels, List<ButtonType> types) {
    return Expanded(
      child: Row(
        children: List.generate(labels.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
              child: CalculatorButton(
                text: labels[i],
                type: types[i],
                onPressed: () => _onButtonPressed(labels[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
