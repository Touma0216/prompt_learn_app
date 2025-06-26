import 'dart:convert';
import 'package:flutter/material.dart';
import '../../ai_category.dart';
import 'conversation_ai_page.dart';
import 'text_ai_page.dart';

class AiLearnCategoryPage extends StatefulWidget {
  const AiLearnCategoryPage({super.key});

  @override
  State<AiLearnCategoryPage> createState() => _AiLearnCategoryPageState();
}

class _AiLearnCategoryPageState extends State<AiLearnCategoryPage> {
  List<AiCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final jsonStr = await DefaultAssetBundle.of(context).loadString('assets/data/categories.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      _categories = jsonList.map((e) => AiCategory.fromJson(e)).toList();
      _loading = false;
    });
  }

  int getCrossAxisCount(double width) {
    if (width <= 400) return 1; // iPhone SEなど
    if (width <= 700) return 2; // 一般スマホ
    if (width <= 1100) return 3; // タブレット・小型PC
    return 4; // PC
  }

  double getCardMinHeight(double width, int crossAxisCount) {
    // 最小でも画像＋テキスト2種＋余白を確保
    if (crossAxisCount == 1) return 240;
    if (crossAxisCount == 2) return 240;
    if (crossAxisCount == 3) return 220;
    return 210;
  }

  void _onCategoryTap(BuildContext context, AiCategory category) {
    if (category.id == "conversation") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ConversationAiListPage()),
      );
    } else if (category.id == "text") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TextAiListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${category.title}は今後実装予定です')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = getCrossAxisCount(width);
    final minHeight = getCardMinHeight(width, crossAxisCount);

    // カードの横幅を計算
    double gridPadding = 12 * 2;
    double crossSpacing = 16 * (crossAxisCount - 1);
    double usableWidth = width - gridPadding - crossSpacing;
    double cardWidth = usableWidth / crossAxisCount;

    // === 固定値で見やすい画像サイズとテキストサイズ ===
    double imageBoxHeight = 120; // スマホ・PC全てで固定値
    double titleFontSize = 17; // 16〜18でバランス
    double descFontSize = 13.5; // 13〜14でバランス

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIジャンルを選ぶ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: GridView.builder(
                    itemCount: _categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 18,
                      childAspectRatio: cardWidth / minHeight, // 縦長に見せる
                    ),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _onCategoryTap(context, category),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 画像（高さ固定、横はカード幅いっぱい）
                                Container(
                                  width: double.infinity,
                                  height: imageBoxHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      category.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Center(
                                        child: Icon(Icons.extension, size: 56, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // タイトル
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    category.title,
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // 説明文
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    category.description,
                                    style: TextStyle(
                                      fontSize: descFontSize,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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