import 'package:flutter/material.dart';
import '../../../widgets/loading_screen.dart';

class AiListPage extends StatelessWidget {
  const AiListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final aiList = [
      {
        'name': 'ChatGPT(OpenAI)',
        'id': 'ChatGPT',
      },
      {
        'name': 'Gemini',
        'id': 'Gemini',
      },
      // 必要に応じて追加
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('AI一覧')),
      body: ListView.builder(
        itemCount: aiList.length,
        itemBuilder: (context, index) {
          final ai = aiList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.smart_toy, size: 32, color: Colors.blueGrey),
              title: Text(ai['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            ),
          );
        },
      ),
    );
  }
}
