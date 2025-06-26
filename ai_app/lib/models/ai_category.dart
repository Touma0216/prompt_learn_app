class AiCategory {
  final String id;
  final String title;
  final String image;
  final String description;

  AiCategory({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
  });

  factory AiCategory.fromJson(Map<String, dynamic> json) {
    return AiCategory(
      id: json['id'],
      title: json['title'],
      image: json['image'] as String? ?? "",
      description: json['description'] as String? ?? "",
    );
  }
}