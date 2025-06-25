import 'package:flutter/material.dart';
import 'models/pages/top_page.dart';

void main() {
  runApp(const PromptLearnApp());
}

class PromptLearnApp extends StatelessWidget {
  const PromptLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIプロンプト学習',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF64B5F6),
      ),
      home: const TopPage(),
    );
  }
}