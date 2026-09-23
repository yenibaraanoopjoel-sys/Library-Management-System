import 'package:flutter/material.dart';

/// Controller coordinating search input debouncing and multi-entity querying
class SearchViewController extends ChangeNotifier {
  final TextEditingController queryController = TextEditingController();

  // TODO: Implement debounced search across books, authors, members
}
