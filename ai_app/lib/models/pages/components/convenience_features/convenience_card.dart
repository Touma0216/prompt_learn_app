import 'package:flutter/material.dart';

class ConvenienceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ConvenienceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
