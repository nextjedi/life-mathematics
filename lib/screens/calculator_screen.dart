import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/calculator_button.dart';
import '../utils/calculator_logic.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorLogic _calculator = CalculatorLogic();

  void _onButtonPressed(String value) {
    setState(() {
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
    final appState = LifeMathematicsApp.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => appState?.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _calculator.displayValue,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            // Buttons
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row 1: C, CE, ⌫, ÷
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CalculatorButton(
                              text: 'C',
                              onPressed: () => _onButtonPressed('C'),
                              type: ButtonType.clear,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: 'CE',
                              onPressed: () => _onButtonPressed('CE'),
                              type: ButtonType.function,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '⌫',
                              onPressed: () => _onButtonPressed('⌫'),
                              type: ButtonType.function,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '÷',
                              onPressed: () => _onButtonPressed('÷'),
                              type: ButtonType.operator,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row 2: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CalculatorButton(
                              text: '7',
                              onPressed: () => _onButtonPressed('7'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '8',
                              onPressed: () => _onButtonPressed('8'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '9',
                              onPressed: () => _onButtonPressed('9'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '×',
                              onPressed: () => _onButtonPressed('×'),
                              type: ButtonType.operator,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row 3: 4, 5, 6, −
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CalculatorButton(
                              text: '4',
                              onPressed: () => _onButtonPressed('4'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '5',
                              onPressed: () => _onButtonPressed('5'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '6',
                              onPressed: () => _onButtonPressed('6'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '−',
                              onPressed: () => _onButtonPressed('−'),
                              type: ButtonType.operator,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CalculatorButton(
                              text: '1',
                              onPressed: () => _onButtonPressed('1'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '2',
                              onPressed: () => _onButtonPressed('2'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '3',
                              onPressed: () => _onButtonPressed('3'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '+',
                              onPressed: () => _onButtonPressed('+'),
                              type: ButtonType.operator,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row 5: ±, 0, ., =
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CalculatorButton(
                              text: '±',
                              onPressed: () => _onButtonPressed('±'),
                              type: ButtonType.function,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '0',
                              onPressed: () => _onButtonPressed('0'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '.',
                              onPressed: () => _onButtonPressed('.'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalculatorButton(
                              text: '=',
                              onPressed: () => _onButtonPressed('='),
                              type: ButtonType.equal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
