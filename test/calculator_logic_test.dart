import 'package:flutter_test/flutter_test.dart';
import 'package:life_mathematics/utils/calculator_logic.dart';

void main() {
  group('CalculatorLogic', () {
    late CalculatorLogic calculator;

    setUp(() {
      calculator = CalculatorLogic();
    });

    test('should start with 0', () {
      expect(calculator.displayValue, '0');
    });

    test('should input numbers correctly', () {
      calculator.inputNumber('5');
      expect(calculator.displayValue, '5');
      calculator.inputNumber('3');
      expect(calculator.displayValue, '53');
    });

    test('should handle decimal input', () {
      calculator.inputNumber('5');
      calculator.inputDecimal();
      calculator.inputNumber('5');
      expect(calculator.displayValue, '5.5');
    });

    test('should not allow multiple decimals', () {
      calculator.inputNumber('5');
      calculator.inputDecimal();
      calculator.inputDecimal();
      calculator.inputNumber('5');
      expect(calculator.displayValue, '5.5');
    });

    test('should perform addition correctly', () {
      calculator.inputNumber('5');
      calculator.inputOperator('+');
      calculator.inputNumber('3');
      calculator.calculate();
      expect(calculator.displayValue, '8');
    });

    test('should perform subtraction correctly', () {
      calculator.inputNumber('5');
      calculator.inputOperator('−');
      calculator.inputNumber('3');
      calculator.calculate();
      expect(calculator.displayValue, '2');
    });

    test('should perform multiplication correctly', () {
      calculator.inputNumber('5');
      calculator.inputOperator('×');
      calculator.inputNumber('3');
      calculator.calculate();
      expect(calculator.displayValue, '15');
    });

    test('should perform division correctly', () {
      calculator.inputNumber('1');
      calculator.inputNumber('5');
      calculator.inputOperator('÷');
      calculator.inputNumber('3');
      calculator.calculate();
      expect(calculator.displayValue, '5');
    });

    test('should clear display', () {
      calculator.inputNumber('5');
      calculator.inputNumber('3');
      calculator.clear();
      expect(calculator.displayValue, '0');
    });

    test('should handle backspace', () {
      calculator.inputNumber('5');
      calculator.inputNumber('3');
      calculator.inputNumber('7');
      calculator.backspace();
      expect(calculator.displayValue, '53');
    });

    test('should toggle sign', () {
      calculator.inputNumber('5');
      calculator.toggleSign();
      expect(calculator.displayValue, '-5');
      calculator.toggleSign();
      expect(calculator.displayValue, '5');
    });

    test('should handle chained operations', () {
      calculator.inputNumber('5');
      calculator.inputOperator('+');
      calculator.inputNumber('3');
      calculator.inputOperator('×');
      calculator.inputNumber('2');
      calculator.calculate();
      expect(calculator.displayValue, '16');
    });

    test('keeps the completed expression on screen after =', () {
      calculator.inputNumber('7');
      calculator.inputOperator('+');
      calculator.inputNumber('8');
      calculator.calculate();
      expect(calculator.displayValue, '15');
      expect(calculator.expression, '7 + 8 =');
    });

    group('error handling', () {
      test('division by zero reports an error', () {
        calculator.inputNumber('5');
        calculator.inputOperator('÷');
        calculator.inputNumber('0');
        calculator.calculate();
        expect(calculator.displayValue, 'Error');
        expect(calculator.hasError, isTrue);
      });

      test('an operator applied to an error is refused, not coerced to 0', () {
        calculator.inputNumber('5');
        calculator.inputOperator('÷');
        calculator.inputNumber('0');
        calculator.calculate();

        calculator.inputOperator('+');
        // The operator is dropped: no pending "Error + …" is built up.
        expect(calculator.displayValue, 'Error');
        expect(calculator.hasError, isTrue);
        expect(calculator.currentOperator, isEmpty);

        // The next digit starts a clean entry instead of continuing the
        // broken one, which used to evaluate "Error + 5" as 0 + 5.
        calculator.inputNumber('5');
        calculator.calculate();
        expect(calculator.displayValue, '5');
        expect(calculator.expression, isEmpty);
        expect(calculator.lastCalculation, isNull);
      });

      test('typing a digit recovers from an error', () {
        calculator.inputNumber('5');
        calculator.inputOperator('÷');
        calculator.inputNumber('0');
        calculator.calculate();

        calculator.inputNumber('7');
        expect(calculator.displayValue, '7');
        expect(calculator.hasError, isFalse);
      });

      test('clear recovers from an error', () {
        calculator.inputNumber('5');
        calculator.inputOperator('÷');
        calculator.inputNumber('0');
        calculator.calculate();
        calculator.clear();
        expect(calculator.displayValue, '0');
        expect(calculator.hasError, isFalse);
      });

      test('an errored calculation is not offered for history', () {
        calculator.inputNumber('5');
        calculator.inputOperator('÷');
        calculator.inputNumber('0');
        calculator.calculate();
        expect(calculator.lastCalculation, isNull);
      });
    });

    group('history hand-off', () {
      test('exposes the expression and result of the last =', () {
        calculator.inputNumber('7');
        calculator.inputOperator('+');
        calculator.inputNumber('8');
        calculator.calculate();

        final done = calculator.lastCalculation;
        expect(done, isNotNull);
        expect(done!.expression, '7 + 8');
        expect(done.result, '15');
      });

      test('is cleared once new input starts', () {
        calculator.inputNumber('2');
        calculator.inputOperator('+');
        calculator.inputNumber('2');
        calculator.calculate();
        expect(calculator.lastCalculation, isNotNull);

        calculator.inputNumber('9');
        expect(calculator.lastCalculation, isNull);
      });
    });

    group('formatting', () {
      test('rounds long decimals but keeps full precision available', () {
        calculator.inputNumber('1');
        calculator.inputNumber('0');
        calculator.inputOperator('÷');
        calculator.inputNumber('3');
        calculator.calculate();

        expect(calculator.displayValue, '3.3333');
        expect(calculator.isResultTruncated, isTrue);
        expect(calculator.fullResult, startsWith('3.3333333333'));
      });

      test('uses scientific notation above the readable range', () {
        calculator.inputNumber('9');
        for (var i = 0; i < 14; i++) {
          calculator.inputNumber('9');
        }
        calculator.inputOperator('×');
        calculator.inputNumber('9');
        calculator.calculate();

        expect(calculator.displayValue, contains('e+'));
      });

      test('an exact result has no trailing decimals', () {
        calculator.inputNumber('4');
        calculator.inputOperator('÷');
        calculator.inputNumber('2');
        calculator.calculate();
        expect(calculator.displayValue, '2');
        expect(calculator.isResultTruncated, isFalse);
      });
    });

    group('running tape', () {
      /// Enters `a op b op c …`, mirroring how a long chain is typed.
      void enterChain(List<String> tokens) {
        for (final token in tokens) {
          if ('0123456789'.contains(token[0])) {
            for (final digit in token.split('')) {
              calculator.inputNumber(digit);
            }
          } else {
            calculator.inputOperator(token);
          }
        }
      }

      test('is empty until the first operator', () {
        calculator.inputNumber('7');
        expect(calculator.tape, isEmpty);
      });

      test('keeps every step of a long chain, not just the last two', () {
        enterChain(['12', '+', '8', '−', '5', '×', '3', '÷', '9', '+', '4']);
        calculator.calculate();

        // The running total collapses to a single number; the tape does not.
        expect(calculator.tape, '12 + 8 − 5 × 3 ÷ 9 + 4 = 9');
        expect(calculator.displayValue, '9');
      });

      test('records ten operands in order', () {
        enterChain([
          '1', '+', '2', '+', '3', '+', '4', '+', '5', //
          '+', '6', '+', '7', '+', '8', '+', '9', '+', '10',
        ]);
        calculator.calculate();
        expect(calculator.tape, '1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 = 55');
      });

      test('continues from the result when an operator follows =', () {
        enterChain(['2', '+', '3']);
        calculator.calculate();
        calculator.inputOperator('×');
        calculator.inputNumber('4');
        calculator.calculate();

        expect(calculator.tape, '2 + 3 = 5 × 4 = 20');
      });

      test('starts a new line when a fresh number follows =', () {
        enterChain(['2', '+', '3']);
        calculator.calculate();
        calculator.inputNumber('9');
        calculator.inputOperator('+');
        calculator.inputNumber('1');
        calculator.calculate();

        expect(calculator.tape, '2 + 3 = 5\n9 + 1 = 10');
      });

      test('swapping a mis-typed operator does not duplicate the term', () {
        enterChain(['6', '+']);
        calculator.inputOperator('×');
        calculator.inputNumber('7');
        calculator.calculate();

        expect(calculator.tape, '6 × 7 = 42');
      });

      test('backspacing an unevaluated operator drops its operand too', () {
        enterChain(['7', '+']);
        calculator.backspace();
        expect(calculator.tape, isEmpty);
        expect(calculator.displayValue, '7');
      });

      test('backspacing a chained operator keeps the spent operand', () {
        enterChain(['4', '+', '5', '−']);
        calculator.backspace();

        // "5" was already folded into the running total, so only the dangling
        // "−" comes back off the tape.
        expect(calculator.tape, '4 + 5');
        expect(calculator.displayValue, '9');
        expect(calculator.currentOperator, isEmpty);
      });

      test('survives = and CE, and is cleared only by C', () {
        enterChain(['3', '+', '4']);
        calculator.calculate();
        expect(calculator.tape, isNotEmpty);

        calculator.clearEntry();
        expect(calculator.tape, '3 + 4 = 7');

        calculator.clear();
        expect(calculator.tape, isEmpty);
      });

      test('shows where a chain failed', () {
        enterChain(['8', '÷', '0']);
        calculator.calculate();
        expect(calculator.tape, '8 ÷ 0 = Error');
      });
    });

    test('caps typed input at maxInputDigits', () {
      for (var i = 0; i < CalculatorLogic.maxInputDigits + 10; i++) {
        calculator.inputNumber('9');
      }
      expect(calculator.displayValue.length, CalculatorLogic.maxInputDigits);
    });

    test('backspacing a just-entered operator restores the operand', () {
      calculator.inputNumber('7');
      calculator.inputOperator('+');
      calculator.backspace();
      expect(calculator.displayValue, '7');
      expect(calculator.currentOperator, isEmpty);
      expect(calculator.previousValue, isEmpty);
    });

    group('restore', () {
      test('loads a stored value onto the display', () {
        calculator.restore('152730.06');
        expect(calculator.displayValue, '152730.06');

        // The restored value behaves as a completed result: typing replaces it.
        calculator.inputNumber('4');
        expect(calculator.displayValue, '4');
      });

      test('rebuilds the tape from the stored working', () {
        calculator.restore('9', expression: '12 + 8 − 5 × 3 ÷ 9 + 4');
        expect(calculator.tape, '12 + 8 − 5 × 3 ÷ 9 + 4 = 9');
        expect(calculator.displayValue, '9');
      });

      test('a restored calculation can be carried on', () {
        calculator.restore('15', expression: '7 + 8');
        calculator.inputOperator('×');
        calculator.inputNumber('2');
        calculator.calculate();

        expect(calculator.tape, '7 + 8 = 15 × 2 = 30');
        expect(calculator.displayValue, '30');
      });

      test('starts a new line when a fresh number follows a restore', () {
        calculator.restore('15', expression: '7 + 8');
        calculator.inputNumber('4');
        calculator.inputOperator('+');
        calculator.inputNumber('1');
        calculator.calculate();

        expect(calculator.tape, '7 + 8 = 15\n4 + 1 = 5');
      });

      test('without working it still restores the bare value', () {
        calculator.restore('42');
        expect(calculator.tape, isEmpty);
        expect(calculator.displayValue, '42');
      });
    });

    group('what gets persisted', () {
      test('stores the whole chain, not the running total', () {
        for (final token in ['1', '+', '2', '+', '3']) {
          if (token == '+') {
            calculator.inputOperator('+');
          } else {
            calculator.inputNumber(token);
          }
        }
        calculator.calculate();

        // Previously this recorded "3 + 3", the running total plus the last
        // operand, which read back as a different sum entirely.
        expect(calculator.lastCalculation!.expression, '1 + 2 + 3');
        expect(calculator.lastCalculation!.result, '6');
      });

      test('a single step is unchanged', () {
        calculator.inputNumber('7');
        calculator.inputOperator('+');
        calculator.inputNumber('8');
        calculator.calculate();
        expect(calculator.lastCalculation!.expression, '7 + 8');
      });
    });
  });
}
