import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

/// Toggle switch for switching between light, dark, and system theme modes
class ThemeSwitchWidget extends StatelessWidget {
  const ThemeSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: themeProvider.isDarkMode,
      onChanged: (_) => themeProvider.toggleTheme(),
    );
  }
}
