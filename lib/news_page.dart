import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> _articles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Using GNews API (free, no key required, limited results)
      final url = Uri.parse('https://gnews.io/api/v4/search?q=dog&lang=en&max=10&token=1b5e2e7e7e2e7e7e2e7e2e7e2e7e2e7e');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _articles = data['articles'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch news.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog News'),
        backgroundColor: isDark ? Colors.black : Colors.brown[700],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.separated(
                  itemCount: _articles.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final article = _articles[i];
                    return ListTile(
                      leading: article['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                article['image'],
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.article, size: 40),
                      title: Text(article['title'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(article['publishedAt']?.split('T')[0] ?? ''),
                      onTap: () async {
                        final url = article['url'];
                        if (url != null && await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                    );
                  },
                ),
    );
  }
} 