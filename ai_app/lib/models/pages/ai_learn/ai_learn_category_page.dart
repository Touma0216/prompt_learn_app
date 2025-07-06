import 'dart:convert';
import 'package:flutter/material.dart';
import '../../ai_category.dart';
import '../components/convenience_features/convenience_card.dart'; // ここ
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
    final jsonStr = await DefaultAssetBundle.of(context).loadString('assets/data/categories.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      _categories = jsonList.map((e) => AiCategory.fromJson(e)).toList();
      _loading = false;
    });
  }

  void _onCategoryTap(BuildContext context, AiCategory category) {
    switch (category.id) {
      case "conversation":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationAiListPage()));
        break;
      case "text":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TextAiListPage()));
        break;
      case "image":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageAiListPage()));
        break;
      case "sound":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SoundAiListPage()));
        break;
      case "programming":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgrammingAiListPage()));
        break;
      case "movie":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MovieAiListPage()));
        break;
      case "data":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DataAiListPage()));
        break;
    }
  }

  IconData _getCategoryIcon(String id) {
    switch (id) {
      case "conversation":
        return Icons.chat_bubble_outline;
      case "text":
        return Icons.text_fields;
      case "image":
        return Icons.image;
      case "sound":
        return Icons.music_note;
      case "programming":
        return Icons.code;
      case "movie":
        return Icons.movie_creation_outlined;
      case "data":
        return Icons.bar_chart;
      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AIジャンルを選ぶ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ConvenienceCard(
                  icon: _getCategoryIcon(category.id),
                  title: category.title,
                  description: category.description,
                  onTap: () => _onCategoryTap(context, category),
                );
              },
            ),
    );
  }
}
