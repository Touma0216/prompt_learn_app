import 'package:flutter/material.dart';
import '../../models/ai_info.dart';
import '../../widgets/ai_card.dart';

/// 「会話するAI」カテゴリのAI一覧ページ
class ConversationAiListPage extends StatelessWidget {
  const ConversationAiListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 仮データ
    final List<AiInfo> aiList = [
      AiInfo(
        name: 'ChatGPT',
        description: 'OpenAIが開発した強力な会話型AI。幅広い話題に対応し、自然な日本語応答が可能。',
        icon: Icons.chat_bubble_rounded,
        strengths: [
          '知識量が豊富',
          '日本語対応が自然',
          'API・サービスが多い',
        ],
        weaknesses: [
          '最新情報は取得できない場合がある',
          '専門分野の正確性に限界',
        ],
        pricing: '無料（有料プランあり）',
        usageExample: '日常会話・学習・プログラミング質問',
        officialUrl: 'https://chat.openai.com/',
      ),
      AiInfo(
        name: 'Gemini',
        description: 'Googleが提供する多用途AI。検索連携やマルチモーダル対応が特徴。',
        icon: Icons.auto_awesome,
        strengths: [
          'Google検索との連携',
          '画像やファイル入力にも対応',
        ],
        weaknesses: [
          '一部機能は英語のみ',
          'API公開範囲が限定的',
        ],
        pricing: '無料（Googleアカウント必要）',
        usageExample: '情報検索・画像解析・Q&A',
        officialUrl: 'https://gemini.google.com/',
      ),
      AiInfo(
        name: 'Claude',
        description: 'Anthropicが開発した対話AI。安全性と長文処理能力に優れる。',
        icon: Icons.lightbulb_circle,
        strengths: [
          '長文の入出力が得意',
          '高い安全性と倫理性',
        ],
        weaknesses: [
          '日本語情報がやや少ない',
          'APIの制限がある',
        ],
        pricing: '無料（有料プランあり）',
        usageExample: '長文要約・ビジネス文書作成',
        officialUrl: 'https://claude.ai/',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('会話するAI 一覧'),
      ),
      body: ListView.builder(
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
      ),
    );
  }
}