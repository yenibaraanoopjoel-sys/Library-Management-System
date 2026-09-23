/// Extension helpers for String manipulation and formatting
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  bool get isValidIsbn {
    final clean = replaceAll('-', '').replaceAll(' ', '');
    return clean.length == 10 || clean.length == 13;
  }
}
