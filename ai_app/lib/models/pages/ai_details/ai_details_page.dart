import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:yaml/yaml.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

/// ------------------------------------------------------------
/// カテゴリごとにピノの画像を分けるウィジェット
class PinoImage extends StatelessWidget {
  final String category;
  const PinoImage({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    String asset;
    switch (category) {
      case 'conversation':
        asset = 'assets/images/pino_talk.png';
        break;
      case 'image':
        asset = 'assets/images/pino_image.png';
        break;
      default:
        asset = 'assets/images/pino_default.png';
    }
    return Image.asset(asset, width: 80, height: 80, fit: BoxFit.contain);
  }
}

/// ------------------------------------------------------------
/// Markdown を `##` ごとに分割した 1 セクション
class _Section {
  final String title;
  final int level;
  String body;
  final GlobalKey key = GlobalKey();
  _Section({required this.title, required this.level, required this.body});
}

/// ------------------------------------------------------------
/// AiDetailPage
///   * json の name をそのまま渡す (例: 'ChatGPT')
///   * 空白を全部削除して <name>.md を assets から読む
class AiDetailPage extends StatefulWidget {
  final String aiName;
  const AiDetailPage({super.key, required this.aiName});

  @override
  State<AiDetailPage> createState() => _AiDetailPageState();
}

class _AiDetailPageState extends State<AiDetailPage> {
  String? _markdownContent;
  Map<String, dynamic>? _aiMetadata;
  List<_Section> _sections = [];
  List<_TocItem> _tableOfContents = [];
  bool _isLoading = true;
  String? errorText;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAiContent();
  }

  /// ----------------------------------------------------------
  /// Markdown 読込
  Future<void> _loadAiContent() async {
    // 空白を取って .md を付ける  ──> ChatGPT → ChatGPT.md / Stable Diffusion → StableDiffusion.md
    final fileName = widget.aiName.replaceAll(' ', '') + '.md';
    final mdPath = 'assets/ai_details_md/$fileName';

    try {
      final raw = await rootBundle.loadString(mdPath);

      // YAML front‑matter を許容するが無くても本文だけで表示できる正規表現
      final reg = RegExp(r'^\s*[\uFEFF]*---\s*\r?\n([\s\S]+?)\r?\n---\s*\r?\n?([\s\S]*)');
      final m = reg.firstMatch(raw);

      String markdownBody;
      Map<String, dynamic> meta = {};
      if (m != null) {
        meta = Map<String, dynamic>.from(yamlMap);
        markdownBody = m.group(2)!;
      } else {
        markdownBody = raw;
      }

      _markdownContent = markdownBody;
      _aiMetadata = meta;
      _parseSections(markdownBody);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorText = 'Markdown が見つかりません (path: $mdPath)';
      });
    }
  }

  /// ----------------------------------------------------------
  /// Markdown を解析してセクションと目次を生成
  void _parseSections(String mdText) {
    final regex = RegExp(r'^(#{1,3})\s+(.*)', multiLine: true);
    final matches = regex.allMatches(mdText);
    if (matches.isEmpty) {
      _sections = [
        _Section(title: '', level: 1, body: mdText.trim()),
      ];
      return;
    }

    _sections = [];
    int lastEnd = 0;
    for (final m in matches) {
      final level = m.group(1)!.length;
      final title = m.group(2)!;
      if (_sections.isNotEmpty) {
        _sections.last.body = mdText.substring(lastEnd, m.start).trim();
      }
      _sections.add(_Section(title: title, level: level, body: ''));
      lastEnd = m.end;
    }
    _sections.last.body = mdText.substring(lastEnd).trim();

    _tableOfContents = _sections
        .where((s) => s.level == 2 || s.level == 3)
        .map((s) => _TocItem(s.title, s.level, s.key))
        .toList();
  }

  /// ----------------------------------------------------------
  /// Markdown の表示スタイル
  MarkdownStyleSheet _style(BuildContext ctx) =>
      MarkdownStyleSheet.fromTheme(Theme.of(ctx)).copyWith(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        p: const TextStyle(fontSize: 16, height: 1.8),
        listBullet: const TextStyle(fontSize: 16),
        code: const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Color(0xFFE0E0E0),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(4),
        ),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          border: Border(left: BorderSide(color: Colors.grey.shade400, width: 4)),
        ),
      );

  /// ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF64B5F6);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorText != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(errorText!)));
    }


    final meta = _aiMetadata ?? {};
    final aiName = meta['aiName']?.toString() ?? widget.aiName;
    final catchPhrase = meta['catchPhrase']?.toString() ?? '';
    final category = meta['aiCategory']?.toString() ?? '';
    final strengths = (meta['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final weaknesses = (meta['weaknesses'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('$aiName の詳細'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.isNotEmpty)
              Center(child: PinoImage(category: category)),
            Center(
              child: Text(aiName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            if (catchPhrase.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(catchPhrase,
                      style: TextStyle(color: accent, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            const SizedBox(height: 12),

            // 強み / 弱みカード
            if (strengths.isNotEmpty || weaknesses.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (strengths.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: const [Icon(Icons.check_circle_outline, color: Colors.green), SizedBox(width: 4), Text('強み')]),
                              ...strengths.map((e) => Text('• $e')),
                            ],
                          ),
                        ),
                      if (weaknesses.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('弱み', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              ...weaknesses.map((e) => Text('• $e')),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            if (_tableOfContents.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text('目次', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ..._tableOfContents.map(
                          (item) => InkWell(
                            onTap: () {
                              final ctx = item.key.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: (item.level - 2) * 16.0, top: 4, bottom: 4),
                            child: Text(item.title, style: const TextStyle(color: Colors.blue)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ..._sections.map(
              (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: s.key,
                    padding: EdgeInsets.only(top: 16, bottom: 4, left: s.level == 3 ? 16 : 0),
                    child: Text(
                      s.title,
                      style: TextStyle(
                        fontSize: s.level == 1
                            ? 24
                            : s.level == 2
                                ? 22
                                : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MarkdownBody(
                    data: s.body,
                    styleSheet: _style(context),
                    imageBuilder: (uri, title, alt) {
                      return Image.asset(uri.path, fit: BoxFit.contain);
                    },
                    onTapLink: (_, href, __) async {
                      if (href == null) return;
                      final uri = Uri.parse(href);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
              ),
            ),          ],
        ),
      ),
    );
  }
}
