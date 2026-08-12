import 'package:flutter/foundation.dart';

/// A calculation handed back to the calculator from History.
typedef RestoredCalculation = ({String value, String? expression});

/// Owns which tab is showing, plus the one-shot hand-off used when History
/// sends a previous result back to the calculator.
class ShellProvider extends ChangeNotifier {
  static const int calculatorTab = 0;
  static const int smartCalcTab = 1;
  static const int historyTab = 2;

  int _index = calculatorTab;
  RestoredCalculation? _pending;

  int get index => _index;

  void setIndex(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }

  /// Sends a stored calculation to the calculator and switches to that tab.
  /// [expression] is the chain that produced [value], so the calculator can
  /// show the working rather than just the answer.
  void restoreToCalculator(String value, {String? expression}) {
    _pending = (value: value, expression: expression);
    _index = calculatorTab;
    notifyListeners();
  }

  /// Reads and clears the pending calculation, so it is applied exactly once.
  RestoredCalculation? takePending() {
    final pending = _pending;
    _pending = null;
    return pending;
  }
}
