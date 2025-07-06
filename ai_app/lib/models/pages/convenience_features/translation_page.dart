import 'package:flutter/material.dart';

class TranslationPage extends StatelessWidget {
  const TranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻訳'),
      ),
      body: const Center(
        child: Text('翻訳機能は今後実装予定です'),
      ),
    );
  }
}