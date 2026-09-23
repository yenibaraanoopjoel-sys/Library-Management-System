import 'package:flutter/material.dart';
import 'route_names.dart';
import '../core/widgets/app_shell.dart';

// Splash & Authentication Screens
import '../features/splash/screens/splash_screen.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/authentication/screens/forgot_password_screen.dart';

// Dashboard Screens
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/dashboard/screens/admin_dashboard_screen.dart';
import '../features/dashboard/screens/librarian_dashboard_screen.dart';
import '../features/dashboard/screens/student_dashboard_screen.dart';

// Books Screens
import '../features/books/screens/book_list_screen.dart';
import '../features/books/screens/book_details_screen.dart';
import '../features/books/screens/add_edit_book_screen.dart';

// Members Screens
import '../features/members/screens/member_list_screen.dart';
import '../features/members/screens/member_details_screen.dart';
import '../features/members/screens/add_edit_member_screen.dart';

// Borrowing Screens
import '../features/borrowing/screens/active_borrowings_screen.dart';
import '../features/borrowing/screens/issue_book_screen.dart';
import '../features/borrowing/screens/borrowing_history_screen.dart';

// Returns Screens
import '../features/returns/screens/return_book_screen.dart';
import '../features/returns/screens/return_history_screen.dart';

// Fines Screens
import '../features/fines/screens/fines_list_screen.dart';
import '../features/fines/screens/fine_details_screen.dart';

// Search Screen
import '../features/search/screens/search_screen.dart';

// Notifications Screen
import '../features/notifications/screens/notifications_screen.dart';

// Profile Screens
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';

// Settings Screen
import '../features/settings/screens/settings_screen.dart';

/// Centralized route generator handling named routes with responsive AppShell wrapping
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? RouteNames.splash;

    switch (routeName) {
      // 1. Splash & Auth Screens (Standalone, no AppShell)
      case RouteNames.splash:
        return _buildRoute(const SplashScreen(), settings);
      case RouteNames.login:
        return _buildRoute(const LoginScreen(), settings);
      case RouteNames.register:
        return _buildRoute(const RegisterScreen(), settings);
      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      // 2. Dashboard Screens
      case RouteNames.dashboard:
        return _buildShelledRoute(const DashboardScreen(), routeName, settings);
      case RouteNames.adminDashboard:
        return _buildShelledRoute(const AdminDashboardScreen(), routeName, settings);
      case RouteNames.librarianDashboard:
        return _buildShelledRoute(const LibrarianDashboardScreen(), routeName, settings);
      case RouteNames.studentDashboard:
        return _buildShelledRoute(const StudentDashboardScreen(), routeName, settings);

      // 3. Books
      case RouteNames.books:
        return _buildShelledRoute(const BookListScreen(), routeName, settings);
      case RouteNames.bookDetails:
        final bookId = settings.arguments as String? ?? 'bk_001';
        return _buildShelledRoute(BookDetailsScreen(bookId: bookId), routeName, settings);
      case RouteNames.addBook:
        return _buildShelledRoute(const AddEditBookScreen(), routeName, settings);
      case RouteNames.editBook:
        final bookId = settings.arguments as String?;
        return _buildShelledRoute(AddEditBookScreen(bookId: bookId), routeName, settings);

      // 4. Members
      case RouteNames.members:
        return _buildShelledRoute(const MemberListScreen(), routeName, settings);
      case RouteNames.memberDetails:
        final memberId = settings.arguments as String? ?? 'mem_001';
        return _buildShelledRoute(MemberDetailsScreen(memberId: memberId), routeName, settings);
      case RouteNames.addMember:
        return _buildShelledRoute(const AddEditMemberScreen(), routeName, settings);
      case RouteNames.editMember:
        final memberId = settings.arguments as String?;
        return _buildShelledRoute(AddEditMemberScreen(memberId: memberId), routeName, settings);

      // 5. Borrowings
      case RouteNames.borrowing:
        return _buildShelledRoute(const ActiveBorrowingsScreen(), routeName, settings);
      case RouteNames.issueBook:
        return _buildShelledRoute(const IssueBookScreen(), routeName, settings);
      case RouteNames.borrowingHistory:
        final memberId = settings.arguments as String?;
        return _buildShelledRoute(BorrowingHistoryScreen(memberId: memberId), routeName, settings);

      // 6. Returns
      case RouteNames.returns:
        return _buildShelledRoute(const ReturnBookScreen(), routeName, settings);
      case RouteNames.returnHistory:
        return _buildShelledRoute(const ReturnHistoryScreen(), routeName, settings);

      // 7. Fines
      case RouteNames.fines:
        return _buildShelledRoute(const FinesListScreen(), routeName, settings);
      case RouteNames.fineDetails:
        final fineId = settings.arguments as String? ?? 'fn_001';
        return _buildShelledRoute(FineDetailsScreen(fineId: fineId), routeName, settings);

      // 8. Global Search
      case RouteNames.search:
        return _buildShelledRoute(const SearchScreen(), routeName, settings);

      // 9. Notifications Center
      case RouteNames.notifications:
        return _buildShelledRoute(const NotificationsScreen(), routeName, settings);

      // 10. User Profile
      case RouteNames.profile:
        return _buildShelledRoute(const ProfileScreen(), routeName, settings);
      case RouteNames.editProfile:
        return _buildShelledRoute(const EditProfileScreen(), routeName, settings);

      // 11. Settings
      case RouteNames.settings:
        return _buildShelledRoute(const SettingsScreen(), routeName, settings);

      // Fallback 404 Route
      default:
        return _buildShelledRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No route defined for ${settings.name}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      _navigatorKey.currentContext!,
                      RouteNames.dashboard,
                    ),
                    child: const Text('Return to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
          routeName,
          settings,
        );
    }
  }

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static MaterialPageRoute _buildShelledRoute(
    Widget child,
    String routeName,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => AppShell(
        currentRoute: routeName,
        child: child,
      ),
      settings: settings,
    );
  }

  static MaterialPageRoute _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }
}
