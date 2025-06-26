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

  // レスポンシブな列数（1〜4列）
  int getCrossAxisCount(double width) {
    if (width >= 1100) return 4; // PC
    if (width >= 700) return 3;  // タブレット
    return 2;                    // スマホ
  }

  // カードごとの最小高さ
  double getCardMinHeight(double width) {
    if (width >= 1100) return 240;
    if (width >= 700) return 240;
    return 260; // スマホはやや高く
  }

  // 正方形画像サイズ（カード幅の約55%、最小90最大160）
  double getImageBoxSize(double cardWidth) {
    double size = cardWidth * 0.55;
    if (size < 90) return 90;
    if (size > 160) return 160;
    return size;
  }

  // テキストサイズ（固定値で安定させる）
  double getTitleFontSize() => 16.5;
  double getDescFontSize() => 13.5;

  void _onCategoryTap(BuildContext context, AiCategory category) {
    if (category.id == "conversation") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationAiListPage()));
    } else if (category.id == "text") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TextAiListPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${category.title}は今後実装予定です')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final int crossAxisCount = getCrossAxisCount(width);
    final double cardMinHeight = getCardMinHeight(width);

    // カードの横幅計算
    double gridPadding = 12 * 2;
    double crossSpacing = 16 * (crossAxisCount - 1);
    double usableWidth = width - gridPadding - crossSpacing;
    double cardWidth = usableWidth / crossAxisCount;
    double imageSize = getImageBoxSize(cardWidth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIジャンルを選ぶ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 18,
                  childAspectRatio: cardWidth / cardMinHeight,
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
                      child: Container(
                        constraints: BoxConstraints(minHeight: cardMinHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 正方形画像枠・中央配置
                            Center(
                              child: Container(
                                width: imageSize,
                                height: imageSize,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.asset(
                                    category.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.extension,
                                      size: imageSize * 0.62,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // ジャンル名（1行、折り返しあり、フォントサイズ固定）
                            Text(
                              category.title,
                              style: TextStyle(
                                fontSize: getTitleFontSize(),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(height: 6),
                            // 補助説明文（2行まで折り返し、オーバーフローなし）
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 32, // 2行分程度
                                maxHeight: 40,
                              ),
                              child: Text(
                                category.description,
                                style: TextStyle(
                                  fontSize: getDescFontSize(),
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}