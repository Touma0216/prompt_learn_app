import 'package:flutter/material.dart';
import 'ai_learn/ai_learn_category_page.dart';

// 仮のPlaceholderPage
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(child: Text('$title（このページは準備中です）')),
    );
  }
}

// トップページ
class TopPage extends StatelessWidget {
  const TopPage({super.key});

  // Drawerメニュー項目
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
            ),
            child: Text(
              'メニュー',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('設定'),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('利用規約'),
          ),
          ListTile(
            leading: Icon(Icons.subscriptions),
            title: Text('サブスク管理'),
          ),
          // 必要に応じて追加
        ],
      ),
    );
  }

  // HeaderAreaウィジェット
  Widget _buildHeaderArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AIと一緒に「プロンプト力」を楽しく伸ばそう！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // 仮Live2Dサムネイル
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.face_retouching_natural, size: 38, color: Color(0xFF64B5F6)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('学習進捗', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    // 仮の進捗バー
                    LinearProgressIndicator(
                      value: 0.25,
                      backgroundColor: Color(0xFFB3E5FC),
                      color: Color(0xFF64B5F6),
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // サブスク誘導
          Center(
            child: TextButton(
              onPressed: () {
                // 仮遷移
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('サブスク機能は近日公開予定です')),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFBBDEFB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text(
                '等身キャラ&追加機能はサブスク限定！',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 主要機能ボタンリスト
  List<Map<String, dynamic>> get _featureButtons => [
        {
          'label': 'AIを学ぶ',
          'icon': Icons.auto_awesome,
          'sub': '',
        },
        {
          'label': 'プロンプトを学ぶ',
          'icon': Icons.edit_note,
          'sub': '',
        },
        {
          'label': 'クイズで遊ぶ',
          'icon': Icons.quiz,
          'sub': '',
        },
        {
          'label': '便利機能',
          'icon': Icons.apps,
          'sub': '',
        },
        {
          'label': 'Live2Dと話す',
          'icon': Icons.chat_bubble_outline,
          'sub': '（サブスク限定）',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('AIプロンプト学習アプリ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        actions: const [],
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeaderArea(context),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    itemCount: _featureButtons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, idx) {
                      final feature = _featureButtons[idx];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size.fromHeight(60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Color(0xFFBBDEFB),
                              width: 1.6,
                            ),
                          ),
                        ),
                        onPressed: () {
                          // ここを修正！「AIを学ぶ」を押したときだけConversationAiListPageへ遷移
                          if (feature['label'] == 'AIを学ぶ') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AiLearnCategoryPage(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlaceholderPage(title: feature['label']),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(feature['icon'], color: Color(0xFF64B5F6), size: 28),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                feature['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if ((feature['sub'] as String).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  feature['sub'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1976D2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 右下Live2Dミニキャラ（仮）
          Positioned(
            right: 16,
            bottom: 20,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 7,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.pets, size: 38, color: Color(0xFF64B5F6)),
            ),
          ),
        ],
      ),
    );
  }
}