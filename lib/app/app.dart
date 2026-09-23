import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/member_provider.dart';
import '../providers/borrowing_provider.dart';
import '../providers/fine_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';

// Routing and Theming
import 'app_router.dart';
import 'app_theme.dart';
import 'app_constants.dart';
import '../routing/route_generator.dart';

/// Root application widget configuring providers, router, and themes.
class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => BorrowingProvider()),
        ChangeNotifierProvider(create: (_) => FineProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: RouteGenerator.navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.initialRoute,
          );
        },
      ),
    );
  }
}
