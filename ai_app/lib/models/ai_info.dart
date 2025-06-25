class AiInfo {
  final String name;
  final String description;
  final String icon;
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

  factory AiInfo.fromJson(Map<String, dynamic> json) {
    return AiInfo(
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      pricing: json['pricing'] as String,
      usageExample: json['usageExample'] as String,
      officialUrl: json['officialUrl'] as String,
    );
  }
}