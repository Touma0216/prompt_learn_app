import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:yaml/yaml.dart';
import 'package:url_launcher/url_launcher.dart';

// ピノ画像仮Widget
class PinoImage extends StatelessWidget {
  final String category;
  const PinoImage({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    String asset;
    switch (category) {
      case 'conversation': asset = 'assets/images/pino_talk.png'; break;
      case 'image': asset = 'assets/images/pino_image.png'; break;
      default: asset = 'assets/images/pino_default.png';
    }
    return Image.asset(asset, width: 80, height: 80, fit: BoxFit.contain);
  }
}

// Markdownセクション
class _MarkdownSection {
  final String title;
  final String content;
  _MarkdownSection(this.title, this.content);
}

class AiDetailPage extends StatefulWidget {
  final String aiId; // 例: "chatgpt"
  const AiDetailPage({super.key, required this.aiId});

  @override
  State<AiDetailPage> createState() => _AiDetailPageState();
}

class _AiDetailPageState extends State<AiDetailPage> {
  String? aiName;
  String? aiCategory;
  String? catchPhrase;
  List<String> strengths = [];
  List<String> weaknesses = [];
  List<_MarkdownSection> sections = [];
  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final mdPath = 'assets/ai_details_md/${widget.aiId}.md';
      final raw = await rootBundle.loadString(mdPath);
      final match = RegExp(r'^---([\s\S]+?)---\s*([\s\S]*)$', multiLine: true).firstMatch(raw);
      if (match == null) throw Exception('YAML front matter not found');
      final yamlStr = match.group(1)!;
      final markdownBody = match.group(2)!;

      final yamlMap = loadYaml(yamlStr) as YamlMap;
      setState(() {
        aiName = yamlMap['aiName'] ?? '';
        aiCategory = yamlMap['aiCategory'] ?? '';
        catchPhrase = yamlMap['catchPhrase'] ?? '';
        strengths = (yamlMap['strengths'] as YamlList?)?.map((e) => e.toString()).toList() ?? [];
        weaknesses = (yamlMap['weaknesses'] as YamlList?)?.map((e) => e.toString()).toList() ?? [];
        sections = _splitMarkdownSections(markdownBody);
        loading = false;
        errorText = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorText = "コンテンツが見つかりません";
      });
    }
  }

  // ## で区切って ExpansionTile のリストに
  List<_MarkdownSection> _splitMarkdownSections(String md) {
    final exp = RegExp(r'\n##\s+');
    final sectionStrings = md.split(exp);
    List<_MarkdownSection> result = [];
    for (int i = 0; i < sectionStrings.length; i++) {
      final section = sectionStrings[i];
      if (i == 0 && !section.trim().startsWith('#')) {
        // 最初の部分（h1で始まらない場合を除外）
        continue;
      }
      String title = '';
      String content = section;
      final hMatch = RegExp(r'^#+\s*(.*)').firstMatch(section.trim());
      if (hMatch != null) {
        title = hMatch.group(1) ?? '';
        content = section.trim().substring(hMatch.group(0)!.length).trim();
      }
      result.add(_MarkdownSection(title, content));
    }
    return result;
  }

  MarkdownStyleSheet _qiitaStyle(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 2),
      h2: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1976D2), height: 2),
      h3: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1976D2), height: 1.7),
      p: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      blockquote: TextStyle(
        color: Colors.grey[900],
        backgroundColor: Colors.grey[100],
        fontStyle: FontStyle.italic,
        fontSize: 15,
        height: 1.5,
      ),
      code: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 15,
        backgroundColor: Color(0xFFF7F7F7),
        color: Color(0xFF37474F),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(6),
      ),
      listBullet: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.7),
      listIndent: 28,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.grey[300]!),
        ),
      ),
      tableHead: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      tableBody: const TextStyle(fontSize: 15),
      a: const TextStyle(color: Color(0xFF1976D2), decoration: TextDecoration.underline),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF64B5F6);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('${aiName ?? ""}の詳細'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1.5,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorText != null
              ? Center(child: Text(errorText!))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (aiCategory != null && aiCategory!.isNotEmpty)
                          Center(child: PinoImage(category: aiCategory!)),
                        if (aiName != null)
                          Center(
                            child: Text(
                              aiName!,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                        if (catchPhrase != null && catchPhrase!.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Text(catchPhrase!,
                                  style: TextStyle(fontSize: 15, color: accentColor, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (strengths.isNotEmpty || weaknesses.isNotEmpty)
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0.6,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (strengths.isNotEmpty)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("強み", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                          ...strengths.map((e) => Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                                  const SizedBox(width: 5),
                                                  Expanded(child: Text(e, style: const TextStyle(fontSize: 14))),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  if (weaknesses.isNotEmpty) const SizedBox(width: 12),
                                  if (weaknesses.isNotEmpty)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("弱み", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                          ...weaknesses.map((e) => Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                                                  const SizedBox(width: 5),
                                                  Expanded(child: Text(e, style: const TextStyle(fontSize: 14))),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ...sections.map((s) => Container(
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
                                title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: MarkdownBody(
                                      data: s.content,
                                      styleSheet: _qiitaStyle(context),
                                      selectable: true,
                                      imageBuilder: (uri, title, alt) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            uri.toString(),
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: 180,
                                            errorBuilder: (context, error, stack) =>
                                                const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                          ),
                                        );
                                      },
                                      onTapLink: (text, href, title) async {
                                        if (href == null) return;
                                        if (await canLaunchUrl(Uri.parse(href))) {
                                          await launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
    );
  }
}