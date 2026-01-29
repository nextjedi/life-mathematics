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

    test('should handle division by zero', () {
      calculator.inputNumber('5');
      calculator.inputOperator('÷');
      calculator.inputNumber('0');
      calculator.calculate();
      expect(calculator.displayValue, 'Error');
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

    test('should calculate percentage', () {
      calculator.inputNumber('5');
      calculator.inputNumber('0');
      calculator.percentage();
      expect(calculator.displayValue, '0.5');
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
  });
}
