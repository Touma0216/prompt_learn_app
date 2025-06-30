import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiDetailsPage extends StatefulWidget {
  final String aiName;
  final String? mdFileName;

  const AiDetailsPage({
    super.key,
    required this.aiName,
    this.mdFileName,
  });

  @override
  State<AiDetailsPage> createState() => _AiDetailsPageState();
}

class MarkdownSection {
  final String title;
  final String level; // "h1" or "h2"
  final String body;
  final GlobalKey key;

  MarkdownSection({
    required this.title,
    required this.level,
    required this.body,
    required this.key,
  });
}

class _AiDetailsPageState extends State<AiDetailsPage> {
  List<MarkdownSection> _sections = [];
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAndParseMarkdown();
  }

  Future<void> _loadAndParseMarkdown() async {
    final mdFile = widget.mdFileName ?? '${widget.aiName}.md';
    final safeFile = mdFile.replaceAll(' ', '').replaceAll('　', '');
    final data = await rootBundle.loadString('assets/ai_details_md/$safeFile');
    final sections = <MarkdownSection>[];

    List<String> lines = LineSplitter.split(data).toList();
    String? currentTitle;
    String? currentLevel;
    List<String> buffer = [];
    GlobalKey? currentKey;

    for (final line in lines) {
      if (line.startsWith('# ')) {
        // flush
        if (currentTitle != null) {
          sections.add(MarkdownSection(
            title: currentTitle,
            level: currentLevel!,
            body: buffer.join('\n'),
            key: currentKey!,
          ));
        }
        currentTitle = line.replaceFirst('# ', '');
        currentLevel = "h1";
        currentKey = GlobalKey();
        buffer = [];
      } else if (line.startsWith('## ')) {
        if (currentTitle != null) {
          sections.add(MarkdownSection(
            title: currentTitle,
            level: currentLevel!,
            body: buffer.join('\n'),
            key: currentKey!,
          ));
        }
        currentTitle = line.replaceFirst('## ', '');
        currentLevel = "h2";
        currentKey = GlobalKey();
        buffer = [];
      } else {
        buffer.add(line);
      }
    }
    // flush last
    if (currentTitle != null) {
      sections.add(MarkdownSection(
        title: currentTitle,
        level: currentLevel!,
        body: buffer.join('\n'),
        key: currentKey!,
      ));
    }

    setState(() {
      _sections = sections;
      _loading = false;
    });
  }

  Widget _buildToc() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '目次',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ..._sections.asMap().entries.map((entry) {
            final section = entry.value;
            final indent = section.level == 'h2' ? 18.0 : 0.0;
            final prefix = section.level == 'h1' ? '■' : '▸';
            final fontWeight = section.level == 'h1' ? FontWeight.bold : FontWeight.normal;
            final fontSize = section.level == 'h1' ? 15.0 : 14.0;
            final color = Colors.blue[800];
            return Padding(
              padding: EdgeInsets.only(left: indent, top: 5, bottom: 5),
              child: GestureDetector(
                onTap: () {
                  final ctx = section.key.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 400),
                      alignment: 0.1,
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      prefix,
                      style: TextStyle(
                        color: color,
                        fontWeight: fontWeight,
                        fontSize: fontSize,
                        fontFamily: "monospace",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        section.title,
                        style: TextStyle(
                          color: color,
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aiName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToc(),
                    const SizedBox(height: 16),
                    ..._sections.map((section) => Container(
                          key: section.key,
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Markdownで見出し
                              MarkdownBody(
                                data: section.level == 'h1'
                                  ? '# ${section.title}'
                                  : '## ${section.title}',
                                styleSheet: MarkdownStyleSheet(
                                  h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // 本文Markdown（区切り線・リスト・テーブル・装飾 全部OK）
                              MarkdownBody(
                                data: section.body,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(fontSize: 16),
                                  blockquote: TextStyle(color: Colors.grey[800], fontStyle: FontStyle.italic),
                                  code: const TextStyle(fontFamily: "monospace", backgroundColor: Color(0xFFF7F7F7)),
                                  tableHead: const TextStyle(fontWeight: FontWeight.bold),
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