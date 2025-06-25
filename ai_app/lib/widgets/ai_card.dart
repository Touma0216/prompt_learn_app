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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(aiInfo.description,
                  style: const TextStyle(fontSize: 14)),
              // ...（以降も画像は一切使わず、全てIconで）
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