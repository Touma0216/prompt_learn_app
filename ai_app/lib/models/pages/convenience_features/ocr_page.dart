import 'package:flutter/material.dart';

class OcrPage extends StatelessWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR'),
      ),
      body: const Center(
        child: Text('OCR機能は今後実装予定です'),
      ),
    );
  }
}