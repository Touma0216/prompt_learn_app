import 'package:flutter/material.dart';
import '../models/ai_info.dart';

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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコンまたは画像＋AI名
              Row(
                children: [
                  (aiInfo.imagePath != null && aiInfo.imagePath!.isNotEmpty)
                      ? ClipOval(
                          child: Image.asset(
                            aiInfo.imagePath!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                          ),
                        )
                      : CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.13),
                          child: Icon(_getMaterialIcon(aiInfo.icon), size: 32, color: Theme.of(context).colorScheme.primary),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      aiInfo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 説明
              Text(
                aiInfo.description,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 14),
              // 強み
              if (aiInfo.strengths.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.thumb_up, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text('強み', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 4),
                ...aiInfo.strengths.map((str) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24),
                    const Icon(Icons.check, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(str, style: const TextStyle(fontSize: 13))),
                  ],
                )),
                const SizedBox(height: 8),
              ],
              // 弱み
              if (aiInfo.weaknesses.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.thumb_down, color: Colors.red, size: 20),
                    const SizedBox(width: 6),
                    Text('弱み', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 4),
                ...aiInfo.weaknesses.map((str) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24),
                    const Icon(Icons.close, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(str, style: const TextStyle(fontSize: 13))),
                  ],
                )),
                const SizedBox(height: 8),
              ],
              // 料金
              if (aiInfo.pricing.isNotEmpty) ...[
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
              ],
              // 使用例
              if (aiInfo.usageExample.isNotEmpty) ...[
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
              ],
              // 公式サイト
              if (aiInfo.officialUrl.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.link, color: Colors.indigo, size: 20),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
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
      'android': Icons.android,
      'star': Icons.star,
      'robot': Icons.smart_toy,
      // 必要に応じて追加
    };
    return iconMap[iconName] ?? Icons.android;
  }
}