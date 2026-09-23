import '../extensions/string_extensions.dart';

/// Form field validators for input forms
class Validators {
  static String? requiredField(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.trim().isValidEmail) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? isbn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ISBN is required';
    }
    if (!value.trim().isValidIsbn) {
      return 'Enter a valid 10 or 13-digit ISBN';
    }
    return null;
  }
}
