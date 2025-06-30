import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:yaml/yaml.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Replace this with your actual PinoImage widget or import it from the correct file.
class PinoImage extends StatelessWidget {
  final String category;
  const PinoImage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder image, replace with your actual implementation.
    return Icon(Icons.image, size: 48, color: Colors.grey);
  }
}


/// ------------------------------------------------------------
/// Markdown を `##` ごとに分割した 1 セクション
class _Section {
  final String title;
  final String body;
  _Section(this.title, this.body);
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
  // メタ情報
  String title = '';
  String catchPhrase = '';
  String category = '';
  List<String> strengths = [];
  List<String> weaknesses = [];
  // 本文
  List<_Section> sections = []; // 未使用だが将来の拡張用
  String markdown = '';

  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  /// ----------------------------------------------------------
  /// Markdown 読込
  Future<void> _loadMarkdown() async {
    // 空白を取って .md を付ける  ──> ChatGPT → ChatGPT.md / Stable Diffusion → StableDiffusion.md
    final fileName = widget.aiName.replaceAll(' ', '') + '.md';
    final mdPath = 'assets/ai_details_md/$fileName';

    try {
      final raw = await rootBundle.loadString(mdPath);

      // YAML front‑matter を許容するが無くても本文だけで表示できる正規表現
      final reg = RegExp(r'^\s*[\uFEFF]*---\s*\r?\n([\s\S]+?)\r?\n---\s*\r?\n?([\s\S]*)');
      final m = reg.firstMatch(raw);

      String markdownBody;
      if (m != null) {
        final yamlMap = loadYaml(m.group(1)!) as YamlMap;
        title = (yamlMap['aiName'] ?? widget.aiName).toString();
        category = (yamlMap['aiCategory'] ?? '').toString();
        catchPhrase = (yamlMap['catchPhrase'] ?? '').toString();
        strengths = (yamlMap['strengths'] as YamlList?)?.map((e) => e.toString()).toList() ?? [];
        weaknesses = (yamlMap['weaknesses'] as YamlList?)?.map((e) => e.toString()).toList() ?? [];
        markdownBody = m.group(2)!;
      } else {
        // YAML が無い場合は全文を本文として表示
        title = widget.aiName;
        markdownBody = raw;
      }

      markdown = markdownBody;
      setState(() => loading = false);
    } catch (e) {
      setState(() {
        loading = false;
        errorText = 'Markdown が見つかりません (path: $mdPath)';
      });
    }
  }

  /// ----------------------------------------------------------

  /// ----------------------------------------------------------
  /// Markdown の表示スタイル
  MarkdownStyleSheet _style(BuildContext ctx) =>
      MarkdownStyleSheet.fromTheme(Theme.of(ctx)).copyWith(
        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        p: const TextStyle(fontSize: 16, height: 1.8),
      );

  /// ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF64B5F6);

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorText != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(errorText!)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('$title の詳細'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.isNotEmpty)
              Center(child: PinoImage(category: category)),
            Center(
              child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                              const Text('強み', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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

            // Markdown本文
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: MarkdownBody(
                data: markdown,
                styleSheet: _style(context),
                onTapLink: (_, href, __) async {
                  if (href == null) return;
                  final uri = Uri.parse(href);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
