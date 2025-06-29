import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AiDetailPage extends StatefulWidget {
  final String jsonPath;
  final String aiName;
  const AiDetailPage({
    Key? key,
    required this.jsonPath,
    required this.aiName,
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

  IconData _sectionIcon(String sectionTitle) {
    if (sectionTitle.contains("強み")) return Icons.thumb_up_alt;
    if (sectionTitle.contains("弱み")) return Icons.thumb_down_alt;
    if (sectionTitle.contains("使い方")) return Icons.lightbulb_outline;
    if (sectionTitle.contains("料金")) return Icons.currency_yen;
    if (sectionTitle.contains("特徴")) return Icons.star_border;
    if (sectionTitle.contains("注意")) return Icons.warning_amber_rounded;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF64B5F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${widget.aiName}の詳細'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sections.isEmpty
              ? const Center(child: Text('データが見つかりませんでした'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ピノイラスト（仮）
                        Center(
                          child: Image.asset(
                            'assets/pino_talk.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 各セクション
                        ..._sections.map((section) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              leading: Icon(
                                _sectionIcon(section["title"] ?? ""),
                                color: accentColor,
                              ),
                              title: Text(
                                section["title"] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(
                                    (section["content"] ?? "").isNotEmpty
                                        ? section["content"]
                                        : '（未入力）',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}