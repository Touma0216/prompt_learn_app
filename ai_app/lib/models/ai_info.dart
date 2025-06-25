import 'package:flutter/material.dart';

/// AIサービスの情報を構造化するクラス。
class AiInfo {
  final String name;
  final String description;
  final IconData icon;
  final List<String> strengths;
  final List<String> weaknesses;
  final String pricing;
  final String usageExample;
  final String officialUrl;

  AiInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.strengths,
    required this.weaknesses,
    required this.pricing,
    required this.usageExample,
    required this.officialUrl,
  });
}