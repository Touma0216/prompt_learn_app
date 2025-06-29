class AiInfo {
  final String name;
  final String description;
  final String icon;
  final String? imagePath;
  final List<String> strengths;
  final List<String> weaknesses;
  final String pricing;
  final String usageExample;
  final String officialUrl;
  final String category;
  final String catchPhrase;
  final String detailJsonPath;

  AiInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.imagePath,
    required this.strengths,
    required this.weaknesses,
    required this.pricing,
    required this.usageExample,
    required this.officialUrl,
    required this.category,
    required this.catchPhrase,
    required this.detailJsonPath,
  });

  factory AiInfo.fromJson(Map<String, dynamic> json) {
    return AiInfo(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'android',
      imagePath: json['imagePath'] ?? '',
      strengths: (json['strengths'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      pricing: json['pricing'] ?? '',
      usageExample: json['usageExample'] ?? '',
      officialUrl: json['officialUrl'] ?? '',
      category: json['category'] ?? 'conversation',
      catchPhrase: json['catchPhrase'] ?? '',
      detailJsonPath: json['detailJsonPath'] ?? '',
    );
  }
}