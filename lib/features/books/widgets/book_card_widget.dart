import 'package:flutter/material.dart';
import '../../../models/book_model.dart';

/// Book display card with thumbnail, title, author, and availability status badge
class BookCardWidget extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookCardWidget({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(book.title),
        subtitle: Text('${book.authorName} • ${book.categoryName}'),
        trailing: Chip(
          label: Text('${book.availableCopies}/${book.totalCopies} Available'),
        ),
      ),
    );
  }
}
