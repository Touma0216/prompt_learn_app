import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class AiDetailsPage extends StatefulWidget {
  final String aiName;
  final String? mdFileName; // オプションでmdファイル名を直接指定可能

  const AiDetailsPage({
    super.key,
    required this.aiName,
    this.mdFileName,
  });

  @override
  State<AiDetailsPage> createState() => _AiDetailsPageState();
}

class _AiDetailsPageState extends State<AiDetailsPage> {
  String _markdownData = '';
  final ScrollController _scrollController = ScrollController();
  final List<_HeadingInfo> _headings = [];
  final List<GlobalKey> _headingKeys = [];

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    // mdファイル名指定なければ {aiName}.md で探す
    final mdFile = widget.mdFileName ?? '${widget.aiName}.md';
    final safeFile = mdFile.replaceAll(' ', '').replaceAll('　', '');
    final data = await rootBundle.loadString('assets/ai_details_md/$safeFile');
    setState(() {
      _markdownData = data;
      _extractHeadings(data);
    });
  }

  void _extractHeadings(String markdown) {
    _headings.clear();
    _headingKeys.clear();
    final lines = LineSplitter.split(markdown).toList();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        _headings.add(_HeadingInfo('h1', trimmed.replaceFirst('# ', '')));
        _headingKeys.add(GlobalKey());
      } else if (trimmed.startsWith('## ')) {
        _headings.add(_HeadingInfo('h2', trimmed.replaceFirst('## ', '')));
        _headingKeys.add(GlobalKey());
      }
    }
  }

  Widget _buildToc() {
    if (_headings.isEmpty) return const SizedBox.shrink();
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ..._headings.asMap().entries.map((entry) {
            final idx = entry.key;
            final heading = entry.value;
            final indent = heading.type == 'h2' ? 18.0 : 0.0;
            final prefix = heading.type == 'h1' ? '■' : '▸';
            final fontWeight = heading.type == 'h1' ? FontWeight.bold : FontWeight.normal;
            final fontSize = heading.type == 'h1' ? 15.0 : 14.0;
            final color = Colors.blue[800];
            return Padding(
              padding: EdgeInsets.only(left: indent, top: 5, bottom: 5),
              child: GestureDetector(
                onTap: () {
                  final key = _headingKeys[idx];
                  final ctx = key.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
                  }
                },
                child: Row(
                  children: [
                    Text(
                      prefix,
                      style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize, fontFamily: "monospace"),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        heading.text,
                        style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize),
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

  Map<String, MarkdownElementBuilder> _headingBuilders() {
    int idx = 0;
    return {
      'h1': _KeyedHeadingBuilder(_headingKeys, () => idx++),
      'h2': _KeyedHeadingBuilder(_headingKeys, () => idx++),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.aiName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _markdownData.isEmpty
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
                    MarkdownBody(
                      data: _markdownData,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16),
                        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      builders: _headingBuilders(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HeadingInfo {
  final String type; // 'h1' or 'h2'
  final String text;
  _HeadingInfo(this.type, this.text);
}

class _KeyedHeadingBuilder extends MarkdownElementBuilder {
  final List<GlobalKey> keys;
  final int Function() getKeyIndex;
  _KeyedHeadingBuilder(this.keys, this.getKeyIndex);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final key = keys.length > getKeyIndex() ? keys[getKeyIndex()] : GlobalKey();
    return Container(
      key: key,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        element.textContent,
        style: preferredStyle,
      ),
    );
  }
}