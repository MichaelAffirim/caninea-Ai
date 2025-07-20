import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyRaw = prefs.getStringList('prediction_history') ?? [];
    setState(() {
      _history = historyRaw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('prediction_history');
    setState(() {
      _history = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        backgroundColor: isDark ? Colors.black : Colors.brown[700],
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Clear History',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text('Are you sure you want to clear all prediction history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _clearHistory();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text(
                    'No prediction history yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.separated(
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = _history[i];
                    return ListTile(
                      leading: item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['imageUrl'],
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.pets, size: 40),
                      title: Text(
                        item['breed'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Confidence: ${(item['confidence'] * 100).toStringAsFixed(2)}%\n${item['date'] != null ? DateTime.tryParse(item['date'])?.toLocal().toString().split(".")[0] : ''}',
                      ),
                    );
                  },
                ),
    );
  }
} 