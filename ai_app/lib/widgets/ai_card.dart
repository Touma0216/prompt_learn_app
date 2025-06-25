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
                    child: Icon(aiInfo.icon, size: 28, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      aiInfo.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                aiInfo.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // 強み
              Row(
                children: [
                  Icon(Icons.thumb_up, color: Colors.green, size: 20),
                  const SizedBox(width: 4),
                  Text('強み', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              ...aiInfo.strengths.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 28, top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(s)),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),

              // 弱み
              Row(
                children: [
                  Icon(Icons.thumb_down, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text('弱み', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              ...aiInfo.weaknesses.map((w) => Padding(
                    padding: const EdgeInsets.only(left: 28, top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(w)),
                      ],
                    ),
                  )),

              const Divider(height: 24),

              // 料金・使用例・公式リンク
              Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber, size: 20),
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
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
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
}