class CalculatorLogic {
  String _displayValue = '0';
  String _previousValue = '';
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _hasDecimal = false;
  String _lastExpression = '';
  String _fullResult = '';

  String get displayValue => _displayValue;
  String get fullResult => _fullResult;

  bool get isResultTruncated =>
      _fullResult.isNotEmpty && _fullResult != _displayValue;

  /// Shows the running expression while typing, or the completed expression
  /// after = is pressed.
  String get expression {
    if (_operator.isNotEmpty) {
      if (_shouldResetDisplay) {
        return '$_previousValue $_operator';
      } else {
        return '$_previousValue $_operator $_displayValue';
      }
    }
    return _lastExpression;
  }

  void inputNumber(String number) {
    _fullResult = '';
    if (_shouldResetDisplay) {
      _lastExpression = '';
      _displayValue = number;
      _shouldResetDisplay = false;
      _hasDecimal = false;
    } else {
      if (_displayValue == '0' && number != '.') {
        _displayValue = number;
      } else {
        _displayValue += number;
      }
    }
  }

  void inputDecimal() {
    _fullResult = '';
    if (_shouldResetDisplay) {
      _lastExpression = '';
      _displayValue = '0.';
      _shouldResetDisplay = false;
      _hasDecimal = true;
    } else if (!_hasDecimal) {
      _displayValue += '.';
      _hasDecimal = true;
    }
  }

  void inputOperator(String op) {
    if (_previousValue.isNotEmpty && !_shouldResetDisplay) {
      calculate();
    }
    _lastExpression = '';
    _fullResult = '';
    _previousValue = _displayValue;
    _operator = op;
    _shouldResetDisplay = true;
    _hasDecimal = false;
  }

  void calculate() {
    if (_previousValue.isEmpty || _operator.isEmpty) return;

    double prev = double.tryParse(_previousValue) ?? 0;
    double current = double.tryParse(_displayValue) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = prev + current;
        break;
      case '−':
        result = prev - current;
        break;
      case '×':
        result = prev * current;
        break;
      case '÷':
        if (current == 0) {
          _displayValue = 'Error';
          _lastExpression = '';
          _clear();
          return;
        }
        result = prev / current;
        break;
      case '%':
        result = prev * (current / 100);
        break;
    }

    _lastExpression = '$_previousValue $_operator $_displayValue =';

    if (result == result.toInt()) {
      _displayValue = result.toInt().toString();
      _fullResult = '';
    } else {
      // Full precision (up to 10 significant decimal places)
      final fullStr =
          result.toStringAsFixed(10).replaceAll(RegExp(r'\.?0+$'), '');
      // Truncated to 4 decimal places
      final truncated =
          result.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
      _displayValue = truncated;
      _fullResult = (fullStr != truncated) ? fullStr : '';
    }

    _previousValue = '';
    _operator = '';
    _shouldResetDisplay = true;
    _hasDecimal = _displayValue.contains('.');
  }

  void clear() {
    _displayValue = '0';
    _previousValue = '';
    _operator = '';
    _shouldResetDisplay = false;
    _hasDecimal = false;
    _lastExpression = '';
    _fullResult = '';
  }

  void _clear() {
    _previousValue = '';
    _operator = '';
    _shouldResetDisplay = true;
  }

  void clearEntry() {
    _displayValue = '0';
    _shouldResetDisplay = false;
    _hasDecimal = false;
    _fullResult = '';
  }

  void backspace() {
    _fullResult = '';
    _lastExpression = '';
    // If an operator was just entered (no new digit yet), undo the operator
    if (_shouldResetDisplay && _operator.isNotEmpty) {
      _operator = '';
      _shouldResetDisplay = false;
      return;
    }
    _shouldResetDisplay = false;
    if (_displayValue.length > 1) {
      if (_displayValue[_displayValue.length - 1] == '.') {
        _hasDecimal = false;
      }
      _displayValue = _displayValue.substring(0, _displayValue.length - 1);
    } else {
      _displayValue = '0';
      _hasDecimal = false;
    }
  }

  void toggleSign() {
    if (_displayValue == '0' || _displayValue == 'Error') return;

    if (_displayValue.startsWith('-')) {
      _displayValue = _displayValue.substring(1);
    } else {
      _displayValue = '-$_displayValue';
    }
  }

  void percentage() {
    double value = double.tryParse(_displayValue) ?? 0;
    value = value / 100;
    _displayValue = value.toString();
    _hasDecimal = true;
  }
}
