import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // バックエンドAPIのURLに合わせて書き換え
  static const String _apiBaseUrl = 'http://localhost:8000'; // FastAPIが起動してるホスト
  static Future<String> translateText({
    required String text,
    required String targetLang,
    required String sourceLang,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/translate');
    final body = json.encode({
      'text': text,
      'target_lang': targetLang,
      'source_lang': sourceLang,
    });
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'] ?? '';
    } else {
      throw Exception('翻訳エラー: ${response.statusCode} ${response.body}');
    }
  }
}
