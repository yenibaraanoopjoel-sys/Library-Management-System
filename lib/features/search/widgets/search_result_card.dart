import 'package:flutter/material.dart';

/// Reusable search result card displaying matching entity
class SearchResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type;
  final VoidCallback? onTap;

  const SearchResultCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Chip(label: Text(type)),
      ),
    );
  }
}
