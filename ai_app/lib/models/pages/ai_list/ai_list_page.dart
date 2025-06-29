import 'package:flutter/material.dart';
import '../ai_details/ai_details_page.dart';

class AiListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 仮のAIデータ例
    final aiList = [
      {
        'name': 'ChatGPT',
        'jsonPath': 'lib/models/pages/ai_details/ai_details_json/chatgpt.json',
        'aiCategory': 'conversation',
        'catchPhrase': '対話で新しい発見を。あなたの相談役AI。',
      },
      {
        'name': 'Gemini',
        'jsonPath': 'lib/models/pages/ai_details/ai_details_json/gemini.json',
        'aiCategory': 'conversation',
        'catchPhrase': 'Googleの次世代AIチャットモデル。',
      },
      // 必要に応じて追加
    ];

    return Scaffold(
      appBar: AppBar(title: Text('AI一覧')),
      body: ListView.builder(
        itemCount: aiList.length,
        itemBuilder: (context, index) {
          final ai = aiList[index];
          return ListTile(
            title: Text(ai['name']!),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiDetailPage(
                    jsonPath: ai['jsonPath']!,
                    aiName: ai['name']!,
                    aiCategory: ai['aiCategory']!,
                    catchPhrase: ai['catchPhrase']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}