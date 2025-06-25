import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ai_category.dart';
import 'conversation_ai_page.dart';
// 他ジャンルの詳細ページもここにimport予定

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
    final jsonStr = await rootBundle.loadString('assets/data/categories.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      _categories = jsonList.map((e) => AiCategory.fromJson(e)).toList();
      _loading = false;
    });
  }

  void _onCategoryTap(BuildContext context, AiCategory category) {
    if (category.id == "conversation") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ConversationAiListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${category.title}は今後実装予定です')),
      );
      // 実装後はここで各ジャンルの詳細ページに遷移
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIジャンルを選ぶ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // スマホは1列, タブレットなら2列に調整可
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                return GestureDetector(
                  onTap: () => _onCategoryTap(context, cat),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              cat.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            cat.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            cat.description,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}