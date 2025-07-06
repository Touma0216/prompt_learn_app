import 'package:flutter/material.dart';
import '../../../widgets/loading_screen.dart';

class AiListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final aiList = [
      {
        'name': 'ChatGPT(OpenAI)',
        'id': 'ChatGPT',      },
      {
        'name': 'Gemini',
        'id': 'Gemini',
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
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoadingScreen(
                    aiName: ai['name']!,
                    aiId: ai['id']!,
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