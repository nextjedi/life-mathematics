import 'package:flutter/foundation.dart';
import '../utils/database_helper.dart';

class HistoryProvider extends ChangeNotifier {
  List<CalculationHistory> _history = [];
  bool _isLoading = false;

  List<CalculationHistory> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _history = await DatabaseHelper.instance.getHistory();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistory(CalculationHistory item) async {
    await DatabaseHelper.instance.insertHistory(item);
    await loadHistory();
  }

  Future<void> deleteHistory(int id) async {
    await DatabaseHelper.instance.deleteHistory(id);
    await loadHistory();
  }

  Future<void> togglePin(int id, bool isPinned) async {
    await DatabaseHelper.instance.updateHistoryPin(id, isPinned);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await DatabaseHelper.instance.clearHistory();
    await loadHistory();
  }
}
