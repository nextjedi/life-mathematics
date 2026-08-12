import 'package:flutter/foundation.dart';
import '../utils/database_helper.dart';

class HistoryProvider extends ChangeNotifier {
  List<CalculationHistory> _history = [];
  bool _isLoading = false;
  String? _error;

  List<CalculationHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await DatabaseHelper.instance.getHistory();
    } catch (e) {
      // Without this the spinner span forever — every failure looked like a
      // slow load. Surface it instead.
      _error = _describe(e);
      _history = [];
      debugPrint('HistoryProvider.loadHistory failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHistory(CalculationHistory item) async {
    try {
      await DatabaseHelper.instance.insertHistory(item);
    } catch (e) {
      _error = _describe(e);
      debugPrint('HistoryProvider.addHistory failed: $e');
      notifyListeners();
      return;
    }
    await loadHistory();
  }

  Future<void> deleteHistory(int id) async {
    await _mutate(() => DatabaseHelper.instance.deleteHistory(id));
  }

  Future<void> togglePin(int id, bool isPinned) async {
    await _mutate(() => DatabaseHelper.instance.updateHistoryPin(id, isPinned));
  }

  Future<void> clearHistory() async {
    await _mutate(() => DatabaseHelper.instance.clearHistory());
  }

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _error = _describe(e);
      debugPrint('HistoryProvider mutation failed: $e');
      notifyListeners();
      return;
    }
    await loadHistory();
  }

  String _describe(Object e) {
    if (kIsWeb) {
      return 'History storage is not available on the web build yet.';
    }
    return 'Could not open calculation history.\n$e';
  }
}
