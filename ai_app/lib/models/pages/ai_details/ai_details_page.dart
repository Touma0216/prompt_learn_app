import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AiDetailPage extends StatefulWidget {
  final String jsonPath;
  final String aiName;
  final String aiCategory;
  final String catchPhrase;

  const AiDetailPage({
    Key? key,
    required this.jsonPath,
    required this.aiName,
    required this.aiCategory,
    required this.catchPhrase,
  }) : super(key: key);

  @override
  State<AiDetailPage> createState() => _AiDetailPageState();
}

class _AiDetailPageState extends State<AiDetailPage> {
  List<Map<String, dynamic>> _sections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final jsonStr = await rootBundle.loadString(widget.jsonPath);
      final List<dynamic> jsonList = json.decode(jsonStr);
      setState(() {
        _sections = jsonList.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _sections = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.aiName}の詳細'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sections.isEmpty
              ? const Center(child: Text('データが見つかりませんでした'))
              : ListView.builder(
                  itemCount: _sections.length,
                  itemBuilder: (context, i) {
                    final section = _sections[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(section['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 6),
                          Text(section['content'] ?? ''),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}