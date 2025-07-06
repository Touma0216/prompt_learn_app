import 'package:flutter/material.dart';
import '../components/convenience_features/convenience_card.dart';
import 'translation_page.dart';
import 'prompt_note_page.dart';
import 'memo_page.dart';
import 'ocr_page.dart';

class ConvenienceListPage extends StatelessWidget {
  const ConvenienceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.language,
        'title': '言語翻訳',
        'description': 'テキストをさまざまな言語に翻訳します。',
        'page': const TranslationPage(),
      },
      {
        'icon': Icons.note,
        'title': 'プロンプトノート',
        'description': 'プロンプトを保存・管理・コピーできます。',
        'page': const PromptNotePage(),
      },
      {
        'icon': Icons.edit_note,
        'title': 'メモ帳',
        'description': 'シンプルなメモ帳機能です。',
        'page': const MemoPage(),
      },
      {
        'icon': Icons.document_scanner,
        'title': 'OCR',
        'description': '画像からテキストを抽出します。',
        'page': const OcrPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('便利機能'),
      ),
      body: ListView.separated(
        itemCount: features.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final feature = features[index];
          return ConvenienceCard(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => feature['page'] as Widget),
              );
            },
          );
        },
      ),
    );
  }
}
