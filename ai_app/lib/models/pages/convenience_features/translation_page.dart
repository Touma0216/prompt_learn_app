import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/convenience_features/translation_service.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({Key? key}) : super(key: key);

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _inputController = TextEditingController();
  final int _maxCharacters = 5000;
  String _translatedText = '';
  String _inputLanguage = 'auto';
  String _outputLanguage = 'JA';
  bool _isLoading = false;
  int _characterCount = 0;

  final Map<String, String> _languages = {
    'auto': '自動検出',
    'EN': '英語',
    'JA': '日本語',
    'ZH': '中国語',
    'KO': '韓国語',
    'ES': 'スペイン語',
    'FR': 'フランス語',
    'DE': 'ドイツ語',
    'IT': 'イタリア語',
    'PT': 'ポルトガル語',
    'RU': 'ロシア語',
    'PL': 'ポーランド語',
    'NL': 'オランダ語',
    'SV': 'スウェーデン語',
    'DA': 'デンマーク語',
    'NO': 'ノルウェー語',
    'FI': 'フィンランド語',
  };

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      setState(() {
        _characterCount = _inputController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    if (_inputLanguage == 'auto') {
      _showSnackBar('自動検出モードでは言語の入れ替えができません');
      return;
    }
    setState(() {
      final temp = _inputLanguage;
      _inputLanguage = _outputLanguage;
      _outputLanguage = temp;
      final inputText = _inputController.text;
      _inputController.text = _translatedText;
      _translatedText = inputText;
    });
  }

  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) {
      _showSnackBar('翻訳したいテキストを入力してください');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final text = await TranslationService.translateText(
        text: _inputController.text,
        targetLang: _outputLanguage,
        sourceLang: _inputLanguage,
      );
      setState(() => _translatedText = text);
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_translatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedText));
      _showSnackBar('翻訳結果をコピーしました');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _showLanguageDialog(bool isInput) async {
    final available = isInput
        ? _languages
        : Map.fromEntries(_languages.entries.where((e) => e.key != 'auto'));
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isInput ? '入力言語を選択' : '出力言語を選択'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: available.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                onTap: () => Navigator.pop(context, entry.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        if (isInput) {
          _inputLanguage = selected;
        } else {
          _outputLanguage = selected;
        }
      });
    }
  }

  Widget _buildLangDropdown(String title, String code, bool isInput) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showLanguageDialog(isInput),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(6)
            ),
            child: Row(
              children: [
                Text(_languages[code] ?? code, style: const TextStyle(fontSize: 16)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLangDropdown('入力言語', _inputLanguage, true),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 6,
              maxLength: _maxCharacters,
              decoration: InputDecoration(
                hintText: '翻訳したい文章を入力...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_characterCount / $_maxCharacters',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLangDropdown('出力言語', _outputLanguage, false),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 110,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _translatedText.isEmpty
                  ? const Center(
                      child: Text('翻訳結果がここに表示されます', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    )
                  : SingleChildScrollView(
                      child: Text(_translatedText, style: const TextStyle(fontSize: 16)),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _translatedText.isNotEmpty ? _copyToClipboard : null,
                  tooltip: 'コピー',
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: _translatedText.isNotEmpty
                      ? () => _showSnackBar('音声読み上げは後日実装')
                      : null,
                  tooltip: '音声読み上げ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.11), blurRadius: 8)],
      ),
      child: IconButton(
        icon: const Icon(Icons.swap_vert, size: 28),
        color: theme.primaryColor,
        onPressed: _swapLanguages,
        tooltip: '言語を入れ替え',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('言語翻訳'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputCard(),
              _buildSwapButton(),
              _buildOutputCard(),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _translateText,
                  icon: const Icon(Icons.g_translate, size: 22),
                  label: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            const SizedBox(width: 10),
                            const Text('翻訳中...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                          ],
                        )
                      : const Text('翻訳する', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 48,
        color: Colors.grey[100],
        child: const Center(child: Text('広告バナー表示エリア', style: TextStyle(color: Colors.grey))),
      ),
    );
  }
}
