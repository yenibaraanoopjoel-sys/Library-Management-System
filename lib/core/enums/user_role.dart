/// User authorization roles
enum UserRole {
  admin,
  librarian,
  member;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.librarian:
        return 'Librarian';
      case UserRole.member:
        return 'Member / Student';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == role.toLowerCase(),
      orElse: () => UserRole.member,
    );
  }
}
