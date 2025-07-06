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
        'icon': Icons.translate,
        'title': '翻訳',
        'description': 'DeepLを使ったシンプル翻訳ツール',
        'page': const TranslationPage(),
      },
      {
        'icon': Icons.note_alt_outlined,
        'title': 'プロンプトノート',
        'description': 'テンプレートを保存・タグ管理',
        'page': const PromptNotePage(),
      },
      {
        'icon': Icons.edit_note,
        'title': 'メモ帳',
        'description': 'シンプルなノートを手軽に作成',
        'page': const MemoPage(),
      },
      {
        'icon': Icons.photo_camera_back,
        'title': 'OCR',
        'description': '画像からテキストを抽出',
        'page': const OcrPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('便利機能'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          return ConvenienceCard(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => feature['page'] as Widget),
              );
            },
          );
        },
      ),
    );
  }
}