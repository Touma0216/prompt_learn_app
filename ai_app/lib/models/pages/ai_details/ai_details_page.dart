import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';

class AiDetailsPage extends StatefulWidget {
  final String aiName;
  final String? htmlFileName;

  const AiDetailsPage({
    super.key,
    required this.aiName,
    this.htmlFileName,
  });

  @override
  State<AiDetailsPage> createState() => _AiDetailsPageState();
}

class HtmlSection {
  final String title;
  final String id;
  final GlobalKey key;

  HtmlSection({
    required this.title,
    required this.id,
    required this.key,
  });
}

class _AiDetailsPageState extends State<AiDetailsPage> {
  String? _htmlData;
  bool _loading = true;
  bool _menuOpen = false;
  final ScrollController _scrollController = ScrollController();
  List<HtmlSection> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadHtmlWithCss();
  }

  Future<void> _loadHtmlWithCss() async {
    try {
      // --- 修正点：スペース除去しない ---
      final aiDir = widget.aiName; // "conversation_ChatGPT"
      final htmlFile = widget.htmlFileName ?? '${widget.aiName}.html'; // "ChatGPT(OpenAI).html"
      final basePath = 'assets/ai_details_layout/$aiDir/';
      final htmlPath = '$basePath$htmlFile';
      final cssPath = '$basePath${htmlFile.replaceAll('.html', '.css')}';

      // HTMLロード
      String html = await rootBundle.loadString(htmlPath);

      // CSSロード（なければ無視）
      String? css;
      try {
        css = await rootBundle.loadString(cssPath);
      } catch (e) {
        css = null;
      }

      // CSSがあれば<head>直後に<link>挿入（data URIでインライン）
      if (css != null && !html.contains('rel="stylesheet"')) {
        if (html.contains(RegExp(r'<head[^>]*>', caseSensitive: false))) {
          html = html.replaceFirstMapped(
            RegExp(r'<head[^>]*>', caseSensitive: false),
            (match) =>
                '${match.group(0)}\n<link rel="stylesheet" type="text/css" href="data:text/css;base64,${base64Encode(css!.codeUnits)}">',
          );
        } else {
          html = html.replaceFirstMapped(
            RegExp(r'<body[^>]*>', caseSensitive: false),
            (match) =>
                '${match.group(0)}\n<style>${css!}</style>',
          );
        }
      }

      setState(() {
        _htmlData = html;
        _sections = _extractSections(html);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _htmlData = '<div style="color:red;">HTML/CSSファイルが見つかりません</div>';
        _sections = [];
        _loading = false;
      });
    }
  }

  List<HtmlSection> _extractSections(String html) {
    final reg = RegExp(r'<h([1-6])[^>]*id="([^"]+)"[^>]*>(.*?)<\/h\1>', caseSensitive: false, dotAll: true);
    final matches = reg.allMatches(html);
    return matches.map((m) {
      final id = m.group(2)!;
      final title = _stripHtmlTags(m.group(3)!);
      return HtmlSection(title: title, id: id, key: GlobalKey());
    }).toList();
  }

  String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
  }

  void _scrollToAnchor(String id) {
    final key = _anchorKeys[id];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.1,
        curve: Curves.easeInOut,
      );
    }
  }

  Map<String, GlobalKey> get _anchorKeys {
    final map = <String, GlobalKey>{};
    for (final section in _sections) {
      map[section.id] = section.key;
    }
    return map;
  }

  Widget _buildToc() {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _sections.map((section) {
          return ListTile(
            title: Text(
              section.title,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            onTap: () {
              setState(() {
                _menuOpen = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToAnchor(section.id);
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildHtmlWithAnchors() {
    if (_htmlData == null) return [];
    final widgets = <Widget>[];
    final reg = RegExp(r'(<h([1-6])[^>]*id="([^"]+)"[^>]*>.*?<\/h\2>)', caseSensitive: false, dotAll: true);
    int last = 0;
    for (final match in reg.allMatches(_htmlData!)) {
      if (match.start > last) {
        widgets.add(Html(
          data: _htmlData!.substring(last, match.start),
        ));
      }
      final id = match.group(3)!;
      final key = _anchorKeys[id];
      widgets.add(
        Container(
          key: key,
          child: Html(data: match.group(1)!),
        ),
      );
      last = match.end;
    }
    if (last < _htmlData!.length) {
      widgets.add(Html(data: _htmlData!.substring(last)));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // AppBarの高さ取得
    final appBarHeight = 56.0;
    final dividerHeight = 1.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 本文（100%幅、左詰め）
                SafeArea(
                  child: Column(
                    children: [
                      // AppBar風：戻る＋AI名＋右端ハンバーガー（三）
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
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                setState(() {
                                  _menuOpen = !_menuOpen;
                                });
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildHtmlWithAnchors(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 目次レイヤー
                if (_menuOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).padding.top + appBarHeight + dividerHeight,
                    // AppBar+Divider分ぴったり下
                    child: Material(
                      elevation: 16,
                      color: Colors.white,
                      child: _buildToc(),
                    ),
                  ),
                // 目次レイヤーの透過背景（タップで閉じる）
                if (_menuOpen)
                  Positioned.fill(
                    top: MediaQuery.of(context).padding.top + appBarHeight + dividerHeight + (_sections.length * 56.0), // 目次リスト下
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _menuOpen = false;
                        });
                      },
                      child: Container(
                        color: Colors.black38,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}