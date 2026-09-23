import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'student_dashboard_screen.dart';

/// Dynamic Dashboard Screen rendering Admin or Student view based on active role
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isStudent) {
      return const StudentDashboardScreen();
    }
    return const AdminDashboardScreen();
  }
}
