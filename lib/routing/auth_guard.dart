import '../core/enums/user_role.dart';
import '../models/user_model.dart';

/// Route guard for role-based authorization and session verification
class AuthGuard {
  static bool canAccessRoute({
    required UserModel? user,
    required String targetRoute,
  }) {
    if (user == null) {
      return false;
    }

    // Role-based restrictions
    // Admin has access to all routes
    if (user.role == UserRole.admin) {
      return true;
    }

    // Librarian restrictions
    if (user.role == UserRole.librarian) {
      return true;
    }

    // Student/Member restrictions
    if (user.role == UserRole.member) {
      // Students cannot add/edit books or members
      const restrictedForStudents = [
        '/books/add',
        '/books/edit',
        '/members/add',
        '/members/edit',
        '/dashboard/admin',
        '/dashboard/librarian',
      ];
      return !restrictedForStudents.contains(targetRoute);
    }

    return false;
  }
}
