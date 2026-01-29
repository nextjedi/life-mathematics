import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../utils/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No calculation history yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${provider.history.length} calculations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _showClearDialog(context, provider),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.history.length,
                itemBuilder: (context, index) {
                  final item = provider.history[index];
                  return _HistoryCard(
                    history: item,
                    onDelete: () => provider.deleteHistory(item.id!),
                    onPin: () => provider.togglePin(item.id!, !item.isPinned),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CalculationHistory history;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const _HistoryCard({
    Key? key,
    required this.history,
    required this.onDelete,
    required this.onPin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(_getIcon()),
        ),
        title: Text(history.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy HH:mm').format(history.timestamp)),
            const SizedBox(height: 4),
            Text(
              _getResultText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                history.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              onPressed: onPin,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _getIcon() {
    switch (history.type) {
      case 'basic_calculator':
        return '=';
      case 'compound_interest':
        return '\$';
      case 'loan':
        return '🏦';
      default:
        return '?';
    }
  }

  String _getResultText() {
    if (history.type == 'basic_calculator') {
      final prev = history.inputs['previousValue'] ?? '';
      final op = history.inputs['operator'] ?? '';
      final current = history.inputs['currentValue'] ?? '';
      final result = history.results['result'] ?? '';
      return '$prev $op $current = $result';
    }
    return history.results.toString();
  }
}
