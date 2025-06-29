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
      },
      {
        'name': 'Gemini',
        'jsonPath': 'lib/models/pages/ai_details/ai_details_json/gemini.json',
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