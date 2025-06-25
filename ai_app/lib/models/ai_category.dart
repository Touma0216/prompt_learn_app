class AiCategory {
  final String id;
  final String title;
  final String imagePath;
  final String description;

  AiCategory({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.description,
  });

  factory AiCategory.fromJson(Map<String, dynamic> json) => AiCategory(
        id: json['id'],
        title: json['title'],
        imagePath: json['image'],
        description: json['description'],
      );
}