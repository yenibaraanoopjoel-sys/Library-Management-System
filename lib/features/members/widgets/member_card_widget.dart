import 'package:flutter/material.dart';
import '../../../models/member_model.dart';

/// Member summary card displaying avatar, membership number, name, and status
class MemberCardWidget extends StatelessWidget {
  final MemberModel member;
  final VoidCallback? onTap;

  const MemberCardWidget({
    super.key,
    required this.member,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(member.name),
        subtitle: Text('Card #${member.membershipNumber} • ${member.email}'),
        trailing: Chip(label: Text(member.status)),
      ),
    );
  }
}
