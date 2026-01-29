class CalculatorLogic {
  String _displayValue = '0';
  String _previousValue = '';
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _hasDecimal = false;

  String get displayValue => _displayValue;
  String get previousValue => _previousValue;
  String get operator => _operator;

  void inputNumber(String number) {
    if (_shouldResetDisplay) {
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
    if (_shouldResetDisplay) {
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
          _clear();
          return;
        }
        result = prev / current;
        break;
      case '%':
        result = prev * (current / 100);
        break;
    }

    // Format result to remove unnecessary decimals
    if (result == result.toInt()) {
      _displayValue = result.toInt().toString();
    } else {
      _displayValue = result.toStringAsFixed(8);
      // Remove trailing zeros
      _displayValue = _displayValue.replaceAll(RegExp(r'\.?0+$'), '');
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
  }

  void backspace() {
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
