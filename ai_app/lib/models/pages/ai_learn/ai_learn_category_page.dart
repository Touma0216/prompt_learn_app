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
    if (width >= 900) return 4; // PC
    if (width >= 600) return 3; // タブレット
    return 2; // スマホ
  }

  double getChildAspectRatio(double width) {
    // 列数ごとにバランス良くする
    if (width >= 900) return 0.95;
    if (width >= 600) return 1.05;
    return 1.1;
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
    final childAspectRatio = getChildAspectRatio(width);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIジャンルを選ぶ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 画像領域
                            SizedBox(
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  category.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.extension, size: 40, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ジャンル名
                            Text(
                              category.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // 説明文
                            Text(
                              category.description,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
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