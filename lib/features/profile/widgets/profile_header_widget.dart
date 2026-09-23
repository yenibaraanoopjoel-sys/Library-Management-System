import 'package:flutter/material.dart';

/// Profile header widget with avatar, name, email, and role badge
class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? photoUrl;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 40, child: Text(name.isNotEmpty ? name[0] : 'U')),
        const SizedBox(height: 12),
        Text(name, style: Theme.of(context).textTheme.titleLarge),
        Text(email, style: Theme.of(context).textTheme.bodyMedium),
        Chip(label: Text(role)),
      ],
    );
  }
}
