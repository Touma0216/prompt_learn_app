class AiInfo {
  final String name;
  final String description;
  final String icon;
  final String? imagePath; // 追加
  final List<String> strengths;
  final List<String> weaknesses;
  final String pricing;
  final String usageExample;
  final String officialUrl;

  AiInfo({
    required this.name,
    required this.description,
    required this.icon,
    this.imagePath, // 追加
    required this.strengths,
    required this.weaknesses,
    required this.pricing,
    required this.usageExample,
    required this.officialUrl,
  });

  factory AiInfo.fromJson(Map<String, dynamic> json) {
    return AiInfo(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'android',
      strengths: (json['strengths'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      pricing: json['pricing'] ?? '',
      usageExample: json['usageExample'] ?? '',
      officialUrl: json['officialUrl'] ?? '',
    );
  }
}