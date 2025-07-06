import 'package:flutter/material.dart';

class MemoPage extends StatelessWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ帳'),
      ),
      body: const Center(
        child: Text('メモ帳機能は今後実装予定です'),
      ),
    );
  }
}