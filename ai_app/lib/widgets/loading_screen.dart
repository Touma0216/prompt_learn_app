import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pages/ai_details/ai_details_page.dart';

class LoadingScreen extends StatefulWidget {
  final String aiName;
  final String aiId;

  const LoadingScreen({
    super.key,
    required this.aiName,
    required this.aiId,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _loadMarkdown(widget.aiId),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AiDetailsPage(
          aiName: widget.aiName,
          aiId: widget.aiId,
          markdownData: results[1] as String,
        ),
      ),
    );
  }

  Future<String> _loadMarkdown(String aiId) async {
    try {
      final path = 'ai_details_layout/$aiId/$aiId.md';
      return await rootBundle.loadString(path);
    } catch (e) {
      return '読み込みエラー：Markdownファイルが見つかりません。\n\nエラー詳細: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'ローディング中です...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
