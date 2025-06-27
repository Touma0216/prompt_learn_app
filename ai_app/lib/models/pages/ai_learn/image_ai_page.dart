import 'dart:convert';
import 'package:flutter/material.dart';
import '../../ai_info.dart';         // ← ../../で"models/ai_info.dart"を参照
import '../../../widgets/ai_card.dart'; // ← ../../../で"widgets/ai_card.dart"を参照
import 'package:flutter/services.dart';

class ImageAiListPage extends StatelessWidget {
  const ImageAiListPage({super.key});

  Future<List<AiInfo>> loadAiList() async {
    final String jsonStr = await rootBundle.loadString('assets/data/image_ai_simple.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => AiInfo.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('絵を作るAI 一覧')),
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