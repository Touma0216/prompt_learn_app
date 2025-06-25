import 'package:flutter/material.dart';

class AiCategory {
  final String id;
  final String title;
  final IconData icon; // ←追加

  AiCategory({
    required this.id,
    required this.title,
    required this.icon,
  });

  factory AiCategory.fromJson(Map<String, dynamic> json) {
    return AiCategory(
      id: json['id'],
      title: json['title'],
      icon: _iconFromString(json['icon'] ?? ""), // ←追加
    );
  }

  // 文字列→IconData の変換テーブル
  static IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'chat_bubble_rounded':
        return Icons.chat_bubble_rounded;
      case 'edit_note':
        return Icons.edit_note;
      case 'translate':
        return Icons.translate;
      case 'spellcheck':
        return Icons.spellcheck;
      case 'content_copy':
        return Icons.content_copy;
      case 'g_translate':
        return Icons.g_translate;
      case 'note_add':
        return Icons.note_add;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'menu_book':
        return Icons.menu_book;
      case 'sync_alt':
        return Icons.sync_alt;
      default:
        return Icons.extension; // デフォルトアイコン
    }
  }
}