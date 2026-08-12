/// A completed calculation, ready to be shown or persisted.
typedef Calculation = ({String expression, String result});

class CalculatorLogic {
  /// Longest number a user may type. Doubles carry ~15-17 significant digits,
  /// so anything beyond this is noise the display would silently round away.
  static const int maxInputDigits = 15;

  /// Above this magnitude a plain decimal string is unreadable (and
  /// `toStringAsFixed` silently falls back to `toString`), so we switch to
  /// scientific notation deliberately rather than by accident.
  static const double _scientificThreshold = 1e15;

  static const String errorText = 'Error';

  /// Oldest tape tokens are dropped past this, so a long session cannot grow
  /// without bound.
  static const int _maxTapeTokens = 400;

  /// Longest expression persisted to history; longer chains are elided from
  /// the front so the most recent steps survive.
  static const int _maxExpressionChars = 240;

  static const String _tapeBreak = '\n';

  String _displayValue = '0';
  String _previousValue = '';
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _hasDecimal = false;
  String _lastExpression = '';
  String _fullResult = '';
  bool _hasError = false;
  Calculation? _lastCalculation;

  /// Every operand and operator entered since the last [clear], in order.
  /// Chained arithmetic collapses to a running total, so without this the
  /// earlier steps of a long calculation are unrecoverable.
  final List<String> _tape = [];
  bool _tapeBreakPending = false;
  int _tapeUndoCount = 0;
  bool _lastOperatorEvaluated = false;

  String get displayValue => _displayValue;
  String get fullResult => _fullResult;
  String get previousValue => _previousValue;
  String get currentOperator => _operator;
  bool get hasError => _hasError;

  /// The full running tape, e.g. `12 + 8 − 5 × 3 = 45`. Empty until the first
  /// operator is pressed; survives `=` and `CE`, cleared only by `C`.
  String get tape {
    final buffer = StringBuffer();
    var atLineStart = true;
    for (final token in _tape) {
      if (token == _tapeBreak) {
        buffer.write('\n');
        atLineStart = true;
        continue;
      }
      if (!atLineStart) buffer.write(' ');
      buffer.write(token);
      atLineStart = false;
    }
    return buffer.toString();
  }

  /// The tape's current line, i.e. everything since the last line break.
  /// This is what gets persisted, so history records the whole chain rather
  /// than the running total and the final operand.
  String _currentLineText() {
    final start = _tape.lastIndexOf(_tapeBreak) + 1;
    final text = _tape.sublist(start).join(' ');
    if (text.length <= _maxExpressionChars) return text;
    return '…${text.substring(text.length - _maxExpressionChars)}';
  }

  void _pushTape(String token) {
    if (_tapeBreakPending) {
      _tapeBreakPending = false;
      if (_tape.isNotEmpty) _tape.add(_tapeBreak);
    }
    _tape.add(token);
    if (_tape.length > _maxTapeTokens) {
      _tape.removeRange(0, _tape.length - _maxTapeTokens);
    }
  }

  /// The most recent completed `=`, or null if nothing has been evaluated
  /// since the last clear. Consumed by the history writer.
  Calculation? get lastCalculation => _lastCalculation;

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

  /// Digits actually entered, ignoring sign and decimal point.
  int get _digitCount =>
      _displayValue.replaceAll(RegExp(r'[^0-9]'), '').length;

  /// True when typing would begin a term unrelated to what the tape already
  /// holds — i.e. straight after `=`. The next tape entry starts a new line.
  bool get _startsDetachedTerm =>
      _shouldResetDisplay && _operator.isEmpty && _tape.isNotEmpty;

  void inputNumber(String number) {
    if (_hasError) clear();
    _fullResult = '';
    if (_shouldResetDisplay) {
      if (_startsDetachedTerm) _tapeBreakPending = true;
      _lastExpression = '';
      _lastCalculation = null;
      _displayValue = number;
      _shouldResetDisplay = false;
      _hasDecimal = false;
    } else {
      if (_digitCount >= maxInputDigits) return;
      if (_displayValue == '0') {
        _displayValue = number;
      } else if (_displayValue == '-0') {
        _displayValue = '-$number';
      } else {
        _displayValue += number;
      }
    }
  }

  void inputDecimal() {
    if (_hasError) clear();
    _fullResult = '';
    if (_shouldResetDisplay) {
      if (_startsDetachedTerm) _tapeBreakPending = true;
      _lastExpression = '';
      _lastCalculation = null;
      _displayValue = '0.';
      _shouldResetDisplay = false;
      _hasDecimal = true;
    } else if (!_hasDecimal) {
      _displayValue += '.';
      _hasDecimal = true;
    }
  }

  void inputOperator(String op) {
    // An operator applied to a failed calculation used to coerce "Error" to 0
    // and quietly produce a wrong answer. Refuse instead.
    if (_hasError) return;

    // Operator pressed twice running: swap it instead of opening a new term.
    if (_shouldResetDisplay && _operator.isNotEmpty) {
      if (_tape.isNotEmpty) _tape[_tape.length - 1] = op;
      _operator = op;
      return;
    }

    // Straight after `=` the tape already ends with the result, so only the
    // operator is new.
    final continuesFromResult = _startsDetachedTerm;
    final operand = _displayValue;
    final evaluated = _previousValue.isNotEmpty && !_shouldResetDisplay;

    if (evaluated) {
      _evaluate();
      if (_hasError) return;
    }

    if (!continuesFromResult) _pushTape(operand);
    _pushTape(op);

    // Backspace can only take back the operator once the operand has been
    // folded into the running total — that term is already spent.
    _lastOperatorEvaluated = evaluated || continuesFromResult;
    _tapeUndoCount = _lastOperatorEvaluated ? 1 : 2;

    _lastExpression = '';
    _lastCalculation = null;
    _fullResult = '';
    _previousValue = _displayValue;
    _operator = op;
    _shouldResetDisplay = true;
    _hasDecimal = false;
  }

  void calculate() {
    if (_hasError) return;
    if (_previousValue.isEmpty || _operator.isEmpty) return;

    final operand = _displayValue;
    _evaluate();

    _pushTape(operand);
    // Captured before the "= result" tokens land, so history stores the whole
    // chain — "1 + 2 + 3", not the running total plus the last operand.
    final chain = _currentLineText();
    _pushTape('=');
    _pushTape(_hasError ? errorText : _displayValue);
    _tapeUndoCount = 0;

    if (!_hasError) {
      _lastCalculation = (expression: chain, result: _displayValue);
    }
  }

  void _evaluate() {
    final double? prev = double.tryParse(_previousValue);
    final double? current = double.tryParse(_displayValue);
    if (prev == null || current == null) {
      _fail();
      return;
    }

    final String expressionText = '$_previousValue $_operator $_displayValue';
    double result;

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
          _fail();
          return;
        }
        result = prev / current;
        break;
      default:
        _fail();
        return;
    }

    if (!result.isFinite) {
      _fail();
      return;
    }

    _lastExpression = '$expressionText =';

    final formatted = _format(result);
    _displayValue = formatted.short;
    _fullResult = formatted.long != formatted.short ? formatted.long : '';

    _lastCalculation = (expression: expressionText, result: _displayValue);

    _previousValue = '';
    _operator = '';
    _shouldResetDisplay = true;
    _hasDecimal = _displayValue.contains('.');
  }

  /// Renders a result twice: a compact form for the display, and a
  /// higher-precision form behind the expand toggle.
  ({String short, String long}) _format(double value) {
    final magnitude = value.abs();

    if (magnitude >= _scientificThreshold ||
        (magnitude > 0 && magnitude < 1e-9)) {
      return (
        short: _trimExponential(value.toStringAsExponential(4)),
        long: _trimExponential(value.toStringAsExponential(12)),
      );
    }

    if (value == value.roundToDouble()) {
      final whole = value.toInt().toString();
      return (short: whole, long: whole);
    }

    final long = _trimZeros(value.toStringAsFixed(10));
    final short = _trimZeros(value.toStringAsFixed(4));
    return (short: short, long: long);
  }

  static String _trimZeros(String s) =>
      s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;

  /// `9.0000e+22` → `9e+22`, keeping the exponent intact.
  static String _trimExponential(String s) {
    final parts = s.split('e');
    if (parts.length != 2) return s;
    return '${_trimZeros(parts[0])}e${parts[1]}';
  }

  void _fail() {
    _displayValue = errorText;
    _previousValue = '';
    _operator = '';
    _lastExpression = '';
    _fullResult = '';
    _lastCalculation = null;
    _shouldResetDisplay = true;
    _hasDecimal = false;
    _hasError = true;
  }

  void clear() {
    _displayValue = '0';
    _previousValue = '';
    _operator = '';
    _shouldResetDisplay = false;
    _hasDecimal = false;
    _lastExpression = '';
    _fullResult = '';
    _hasError = false;
    _lastCalculation = null;
    _tape.clear();
    _tapeBreakPending = false;
    _tapeUndoCount = 0;
  }

  void clearEntry() {
    if (_hasError) {
      clear();
      return;
    }
    _displayValue = '0';
    _shouldResetDisplay = false;
    _hasDecimal = false;
    _fullResult = '';
  }

  void backspace() {
    if (_hasError) {
      clear();
      return;
    }
    _fullResult = '';
    _lastExpression = '';
    _lastCalculation = null;
    // If an operator was just entered (no new digit yet), undo the operator
    // and restore the left-hand operand so nothing is left dangling. The tape
    // rewinds by exactly what that operator press appended.
    if (_shouldResetDisplay && _operator.isNotEmpty) {
      if (_tapeUndoCount > 0 && _tapeUndoCount <= _tape.length) {
        _tape.removeRange(_tape.length - _tapeUndoCount, _tape.length);
      }
      _tapeUndoCount = 0;
      _displayValue = _previousValue;
      _previousValue = '';
      _operator = '';
      // If the operand was already folded into the running total, the value on
      // screen is a result: the next digit starts a new term rather than
      // appending to it, which would leave the tape describing a stale number.
      _shouldResetDisplay = _lastOperatorEvaluated;
      _lastOperatorEvaluated = false;
      _hasDecimal = _displayValue.contains('.');
      return;
    }
    _shouldResetDisplay = false;
    if (_displayValue.length > 1 && _displayValue != '-0') {
      if (_displayValue[_displayValue.length - 1] == '.') {
        _hasDecimal = false;
      }
      _displayValue = _displayValue.substring(0, _displayValue.length - 1);
      if (_displayValue == '-') _displayValue = '0';
    } else {
      _displayValue = '0';
      _hasDecimal = false;
    }
  }

  void toggleSign() {
    if (_hasError || _displayValue == '0') return;

    if (_displayValue.startsWith('-')) {
      _displayValue = _displayValue.substring(1);
    } else {
      _displayValue = '-$_displayValue';
    }
  }

  /// Loads a stored calculation back onto the display, e.g. from history.
  ///
  /// [expression] is the chain that produced [value]; supplying it rebuilds
  /// the tape so the restored entry reads exactly as it did when computed,
  /// instead of dropping the user at a bare number with no context.
  void restore(String value, {String? expression}) {
    clear();
    if (value.isEmpty) return;
    _displayValue = value;
    _shouldResetDisplay = true;
    _hasDecimal = value.contains('.');

    if (expression == null || expression.isEmpty) return;
    // Pushed as one token: the tape joins on spaces, so a pre-formatted chain
    // renders identically to one built key by key.
    _pushTape(expression);
    _pushTape('=');
    _pushTape(value);
  }
}
