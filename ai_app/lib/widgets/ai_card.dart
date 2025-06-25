import 'package:flutter/material.dart';
import '../models/ai_info.dart';

/// 個別AIカードウィジェット（再利用可能設計）
class AiCard extends StatelessWidget {
  final AiInfo aiInfo;
  final VoidCallback? onTap;

  const AiCard({
    super.key,
    required this.aiInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコン＋AI名＋概要
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: Icon(_getMaterialIcon(aiInfo.icon), size: 28, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      aiInfo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                aiInfo.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: aiInfo.strengths
                    .map((str) => Chip(
                          label: Text(str, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green.shade50,
                        ))
                    .toList(),
              ),
              Wrap(
                spacing: 8,
                children: aiInfo.weaknesses
                    .map((str) => Chip(
                          label: Text(str, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.red.shade50,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 4),
                  Text('料金:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(aiInfo.pricing)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.tips_and_updates, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 4),
                  Text('使用例:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(aiInfo.usageExample)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.link, color: Colors.indigo, size: 20),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      // 今後url_launcherで公式ページ遷移予定
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('公式サイト遷移は今後実装予定です')),
                      );
                    },
                    child: Text(
                      '公式サイト',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String iconName) {
    const iconMap = {
      'chat_bubble_rounded': Icons.chat_bubble_rounded,
      'auto_awesome': Icons.auto_awesome,
      'lightbulb_circle': Icons.lightbulb_circle,
      // 必要に応じて追加
    };
    return iconMap[iconName] ?? Icons.android;
  }
}