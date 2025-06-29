import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// --- モデルクラス ---
class AIExplainSection {
  final String title;
  final String content;

  AIExplainSection({
    required this.title,
    required this.content,
  });

  factory AIExplainSection.fromJson(Map<String, dynamic> json) {
    return AIExplainSection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

// --- 詳細ページ ---
class AiDetailPage extends StatefulWidget {
  final String jsonPath; // 例: 'assets/data/ai_details/ai_details_json/conversation_ai.json'
  final String aiName;
  final String? imagePath; // アイキャッチ画像（将来拡張用）

  const AiDetailPage({
    super.key,
    required this.jsonPath,
    required this.aiName,
    this.imagePath,
  });

  @override
  State<AiDetailPage> createState() => _AiDetailPageState();
}

class _AiDetailPageState extends State<AiDetailPage> {
  late Future<List<AIExplainSection>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _loadSections();
  }

  Future<List<AIExplainSection>> _loadSections() async {
    final String jsonStr = await rootBundle.loadString(widget.jsonPath);
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => AIExplainSection.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.aiName}の詳細"),
      ),
      body: FutureBuilder<List<AIExplainSection>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("データが見つかりませんでした"));
          }
          final sections = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: Text(
                    section.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: MarkdownBody(
                        data: section.content.isNotEmpty
                            ? section.content
                            : "_（未入力）_",
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context),
                        ).copyWith(
                          p: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}