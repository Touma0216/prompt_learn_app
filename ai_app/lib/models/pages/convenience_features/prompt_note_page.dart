import 'package:flutter/material.dart';

class PromptNotePage extends StatelessWidget {
  const PromptNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロンプトノート'),
      ),
      body: const Center(
        child: Text('プロンプトノートは今後実装予定です'),
      ),
    );
  }
}