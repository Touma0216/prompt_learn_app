import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiDetailsPage extends StatefulWidget {
  final String aiName;
  final String? aiId;
  final String? htmlFileName;

  const AiDetailsPage({
    super.key,
    required this.aiName,
    this.aiId,
    this.htmlFileName,
  });

  @override
  State<AiDetailsPage> createState() => _AiDetailsPageState();
}

class MarkdownSection {
  final String title;
  final GlobalKey key;

  MarkdownSection(this.title, this.key);
}

class _AiDetailsPageState extends State<AiDetailsPage> {
  String? _markdownData;
  bool _loading = true;
  bool _menuOpen = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final List<MarkdownSection> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final id = widget.aiId ?? widget.aiName;
      final fileName = widget.htmlFileName ?? '$id.md';
      final path = 'ai_details_layout/$id/$fileName';

      final markdown = await rootBundle.loadString(path);

      final sectionTitles = _extractHeadings(markdown);
      for (var title in sectionTitles) {
        _sectionKeys[title] = GlobalKey();
        _sections.add(MarkdownSection(title, _sectionKeys[title]!));
      }

      setState(() {
        _markdownData = markdown;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _markdownData = '読み込みエラー：Markdownファイルが見つかりません。';
        _loading = false;
      });
    }
  }

  List<String> _extractHeadings(String markdown) {
    final lines = markdown.split('\n');
    final headings = <String>[];
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        headings.add(trimmed.replaceFirst('# ', '').trim());
      } else if (trimmed.startsWith('## ')) {
        headings.add(trimmed.replaceFirst('## ', '').trim());
      }
    }
    return headings;
  }

  void _scrollToSection(String title) {
    final key = _sectionKeys[title];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Widget> _buildMarkdownWidgets() {
    if (_markdownData == null) return [];
    final lines = _markdownData!.split('\n');
    final widgets = <Widget>[];
    final buffer = StringBuffer();

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ') || trimmed.startsWith('## ')) {
        if (buffer.isNotEmpty) {
          widgets.add(MarkdownBody(
            data: buffer.toString(),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
            imageBuilder: (uri, _, __) => Image.asset(uri.path),
          ));
          buffer.clear();
        }
        final title = trimmed.replaceFirst(RegExp(r'^#+ '), '').trim();
        widgets.add(Container(
          key: _sectionKeys[title],
          child: MarkdownBody(
            data: line,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
          ),
        ));
      } else {
        buffer.writeln(line);
      }
    }
    if (buffer.isNotEmpty) {
      widgets.add(MarkdownBody(
        data: buffer.toString(),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
        imageBuilder: (uri, _, __) => Image.asset(uri.path),
      ));
    }

    return widgets;
  }

  Widget _buildTocMenu() {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📚 目次',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ..._sections.map((section) {
            return ListTile(
              title: Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {
                _scrollToSection(section.title);
                setState(() => _menuOpen = false);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = 56.0;
    final dividerHeight = 1.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: appBarHeight,
                        color: Colors.white,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              widget.aiName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                setState(() => _menuOpen = !_menuOpen);
                              },
                              tooltip: '目次を開く',
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildMarkdownWidgets(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_menuOpen)
                  ...[
                    // 暗転エリア（AppBarと目次以外）
                    Positioned.fill(
                      top: MediaQuery.of(context).padding.top +
                          appBarHeight +
                          dividerHeight +
                          (_sections.length * 56.0 + 56),
                      child: GestureDetector(
                        onTap: () => setState(() => _menuOpen = false),
                        child: Container(color: Colors.black38),
                      ),
                    ),

                    // 明るい目次（タイトル＋リスト）
                    Positioned(
                      top: MediaQuery.of(context).padding.top + appBarHeight + dividerHeight,
                      left: 0,
                      right: 0,
                      child: _buildTocMenu(),
                    ),
                  ],
              ],
            ),
    );
  }
}
