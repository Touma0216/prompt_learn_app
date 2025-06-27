import 'dart:convert';
import 'package:flutter/material.dart';
import '../../ai_info.dart';
import '../../../widgets/ai_card.dart';
import 'package:flutter/services.dart';

class SearchableAiListPage extends StatefulWidget {
  final String jsonPath;
  final String title;

  const SearchableAiListPage({
    super.key,
    required this.jsonPath,
    required this.title,
  });

  @override
  State<SearchableAiListPage> createState() => _SearchableAiListPageState();
}

class _SearchableAiListPageState extends State<SearchableAiListPage> {
  List<AiInfo> _aiList = [];
  List<AiInfo> _filteredList = [];
  bool _loading = true;
  String _searchText = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAiList();
  }

  Future<void> _loadAiList() async {
    final String jsonStr = await rootBundle.loadString(widget.jsonPath);
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      _aiList = jsonList.map((e) => AiInfo.fromJson(e)).toList();
      _filteredList = _aiList;
      _loading = false;
    });
  }

  void _onSearchChanged(String text) {
    setState(() {
      _searchText = text;
      if (text.isEmpty) {
        _filteredList = _aiList;
      } else {
        _filteredList = _aiList.where((ai) {
          final lower = text.toLowerCase();
          return ai.name.toLowerCase().contains(lower) ||
              ai.description.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'AI名や説明で検索',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredList.isEmpty
                      ? const Center(
                          child: Text(
                            '該当するAIは見つかりませんでした',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final ai = _filteredList[index];
                            return AiCard(
                              aiInfo: ai,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${ai.name}：詳細ページへ遷移予定')),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}