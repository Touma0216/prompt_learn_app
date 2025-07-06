import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiDetailsPage extends StatefulWidget {
  final String aiName;
  final String? aiId;
  final String? htmlFileName;
  final String? markdownData;

  const AiDetailsPage({
    super.key,
    required this.aiName,
    this.aiId,
    this.htmlFileName,
    this.markdownData,
  });

  @override
  State<AiDetailsPage> createState() => _AiDetailsPageState();
}

class MarkdownSection {
  final String title;
  final String uniqueKey;
  final int level;
  final GlobalKey key;

  MarkdownSection(this.title, this.uniqueKey, this.level, this.key);
}

class _AiDetailsPageState extends State<AiDetailsPage> with SingleTickerProviderStateMixin {
  String? _markdownData;
  bool _loading = true;
  bool _menuOpen = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final List<MarkdownSection> _sections = [];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.markdownData != null) {
      _initializeMarkdown(widget.markdownData!);
    } else {
      _loadMarkdown();
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMarkdown() async {
    try {
      final id = widget.aiId ?? widget.aiName;
      final fileName = widget.htmlFileName ?? '$id.md';
      final path = 'ai_details_layout/$id/$fileName';
      final markdown = await rootBundle.loadString(path);
      _initializeMarkdown(markdown);
    } catch (e) {
      setState(() {
        _markdownData = '読み込みエラー：Markdownファイルが見つかりません。\n\nエラー詳細: ${e.toString()}';
        _loading = false;
      });
    }
  }

  void _initializeMarkdown(String markdown) {
    final sections = _extractHeadings(markdown);
    _sections.clear();
    _sectionKeys.clear();
    for (var section in sections) {
      _sectionKeys[section.uniqueKey] = GlobalKey();
      _sections.add(MarkdownSection(
        section.title,
        section.uniqueKey,
        section.level,
        _sectionKeys[section.uniqueKey]!,
      ));
    }
    setState(() {
      _markdownData = markdown;
      _loading = false;
    });
  }

  List<MarkdownSection> _extractHeadings(String markdown) {
    final lines = markdown.split('\n');
    final sections = <MarkdownSection>[];
    final titleCounts = <String, int>{};
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.startsWith('# ') || trimmed.startsWith('## ')) {
        final level = trimmed.startsWith('# ') ? 1 : 2;
        final title = trimmed.replaceFirst(RegExp(r'^#+ '), '').trim();
        if (title.isNotEmpty) {
          titleCounts[title] = (titleCounts[title] ?? 0) + 1;
          final uniqueKey = titleCounts[title]! > 1
              ? '${title}_${titleCounts[title]}'
              : title;
          sections.add(MarkdownSection(
            title,
            uniqueKey,
            level,
            GlobalKey(),
          ));
        }
      }
    }
    return sections;
  }

  void _scrollToSection(String uniqueKey) {
    final key = _sectionKeys[uniqueKey];
    if (key?.currentContext != null) {
      try {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        debugPrint('スクロールエラー: $e');
      }
    }
  }

  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
    });
    if (_menuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeMenu() {
    setState(() {
      _menuOpen = false;
    });
    _animationController.reverse();
  }

  List<Widget> _buildMarkdownWidgets() {
    if (_markdownData == null) return [];
    final lines = _markdownData!.split('\n');
    final widgets = <Widget>[];
    final buffer = StringBuffer();
    final titleCounts = <String, int>{};

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('# ') || trimmed.startsWith('## ')) {
        if (buffer.isNotEmpty) {
          widgets.add(MarkdownBody(
            data: buffer.toString(),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
            // simple.png等をMarkdown内で ![]() で呼べるように
            imageBuilder: (uri, _, __) => Image.asset(uri.path),
          ));
          buffer.clear();
        }
        final title = trimmed.replaceFirst(RegExp(r'^#+ '), '').trim();
        if (title.isNotEmpty) {
          titleCounts[title] = (titleCounts[title] ?? 0) + 1;
          final uniqueKey = titleCounts[title]! > 1
              ? '${title}_${titleCounts[title]}'
              : title;
          widgets.add(Container(
            key: _sectionKeys[uniqueKey],
            child: MarkdownBody(
              data: line,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
            ),
          ));
        }
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
    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        elevation: 8,
        color: Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
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
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _sections.map((section) {
                      return ListTile(
                        contentPadding: EdgeInsets.only(
                          left: section.level == 1 ? 16.0 : 32.0,
                          right: 16.0,
                        ),
                        title: Text(
                          section.title,
                          style: TextStyle(
                            fontSize: section.level == 1 ? 16.0 : 14.0,
                            fontWeight: section.level == 1 ? FontWeight.w600 : FontWeight.normal,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          _scrollToSection(section.uniqueKey);
                          _closeMenu();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = 56.0;
    final dividerHeight = 1.0;
    final menuTop = MediaQuery.of(context).padding.top + appBarHeight + dividerHeight;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      SizedBox(
                        height: appBarHeight,
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Expanded(
                                child: Text(
                                  widget.aiName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: _toggleMenu,
                                tooltip: '目次を開く',
                              ),
                            ],
                          ),
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
                  Positioned.fill(
                    top: menuTop,
                    child: GestureDetector(
                      onTap: _closeMenu,
                      child: Container(color: Colors.black38),
                    ),
                  ),
                if (_menuOpen)
                  Positioned(
                    top: menuTop,
                    left: 0,
                    right: 0,
                    child: _buildTocMenu(),
                  ),
              ],
            ),
    );
  }
}
