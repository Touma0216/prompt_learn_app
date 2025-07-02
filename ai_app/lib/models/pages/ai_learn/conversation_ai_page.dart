import 'package:flutter/material.dart';
import '../../ai_info.dart';
import '../../../widgets/ai_card.dart';
import '../ai_details/ai_details_page.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ConversationAiListPage extends StatefulWidget {
  const ConversationAiListPage({super.key});

  @override
  State<ConversationAiListPage> createState() => _ConversationAiListPageState();
}

class _ConversationAiListPageState extends State<ConversationAiListPage> {
  List<AiInfo> _aiList = [];
  List<AiInfo> _filteredList = [];
  bool _loading = true;
  String _searchText = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAiList();
  }

  Future<void> loadAiList() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/data/conversation_ai_simple.json',
    );
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
        final lower = text.toLowerCase();
        _filteredList = _aiList
            .where((ai) => ai.name.toLowerCase().contains(lower))
            .toList();
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
      appBar: AppBar(title: const Text('会話するAI 一覧')),
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
                      hintText: 'AI名で検索',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
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
                      : ListView.builder(
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final ai = _filteredList[index];
                            return AiCard(
                              aiInfo: ai,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AiDetailsPage(
                                      aiName: ai.name,
                                      aiId: ai.id,                                    ),
                                  ),
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