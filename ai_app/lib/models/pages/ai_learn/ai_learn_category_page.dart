import 'dart:convert';
import 'package:flutter/material.dart';
import '../../ai_category.dart';
import 'conversation_ai_page.dart';
import 'text_ai_page.dart';
import 'image_ai_page.dart';
import 'sound_ai_page.dart';
import 'programming_ai_page.dart';
import 'movie_ai_page.dart';
import 'data_ai_page.dart';

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
    final jsonStr = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/categories.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      _categories = jsonList.map((e) => AiCategory.fromJson(e)).toList();
      _loading = false;
    });
  }

  void _onCategoryTap(BuildContext context, AiCategory category) {
    switch (category.id) {
      case "conversation":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConversationAiListPage()),
        );
        break;
      case "text":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TextAiListPage()),
        );
        break;
      case "image":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ImageAiListPage()),
        );
        break;
      case "sound":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SoundAiListPage()),
        );
        break;
      case "programming":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgrammingAiListPage()),
        );
        break;
      case "movie":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MovieAiListPage()),
        );
        break;
      case "data":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DataAiListPage()),
        );
        break;
    }
  }

  int _calcCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('AIジャンルを選ぶ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (isMobile
                ? _MobileCategoryGrid(
                    categories: _categories,
                    onCategoryTap: _onCategoryTap,
                    calcCrossAxisCount: _calcCrossAxisCount,
                  )
                : _WebCategoryGrid(
                    categories: _categories,
                    onCategoryTap: _onCategoryTap,
                    calcCrossAxisCount: _calcCrossAxisCount,
                  )),
    );
  }
}

// 以下は既存のまま
class _MobileCategoryGrid extends StatelessWidget {
  final List<AiCategory> categories;
  final void Function(BuildContext, AiCategory) onCategoryTap;
  final int Function(BuildContext) calcCrossAxisCount;

  const _MobileCategoryGrid({
    required this.categories,
    required this.onCategoryTap,
    required this.calcCrossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calcCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onCategoryTap(context, category),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(
                            category.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.extension,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WebCategoryGrid extends StatelessWidget {
  final List<AiCategory> categories;
  final void Function(BuildContext, AiCategory) onCategoryTap;
  final int Function(BuildContext) calcCrossAxisCount;

  const _WebCategoryGrid({
    required this.categories,
    required this.onCategoryTap,
    required this.calcCrossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calcCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onCategoryTap(context, category),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(
                            category.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.extension,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
