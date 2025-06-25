import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prompt_learn_app/models/ai_info.dart';
import 'package:prompt_learn_app/widgets/ai_card.dart';

IconData getMaterialIcon(String iconName) {
  const iconMap = {
    'chat_bubble_rounded': Icons.chat_bubble_rounded,
    'auto_awesome': Icons.auto_awesome,
    'lightbulb_circle': Icons.lightbulb_circle,
    // 必要なら他も追加
  };
  return iconMap[iconName] ?? Icons.android;
}

class ConversationAiListPage extends StatelessWidget {
  const ConversationAiListPage({super.key});

  Future<List<AiInfo>> loadAiList() async {
    final String jsonStr = await rootBundle.loadString('assets/data/conversation_ai.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => AiInfo.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('会話するAI 一覧')),
      body: FutureBuilder<List<AiInfo>>(
        future: loadAiList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('データがありません'));
          }
          final aiList = snapshot.data!;
          return ListView.builder(
            itemCount: aiList.length,
            itemBuilder: (context, index) {
              final ai = aiList[index];
              return AiCard(
                aiInfo: ai,
                iconData: getMaterialIcon(ai.icon),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${ai.name}：詳細ページへ遷移予定')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}