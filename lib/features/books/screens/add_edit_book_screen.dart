import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/book_provider.dart';
import '../../../models/book_model.dart';
import '../../../core/enums/book_status.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Screen for adding a new book to the library catalog or editing existing book metadata
class AddEditBookScreen extends StatefulWidget {
  final String? bookId;

  const AddEditBookScreen({super.key, this.bookId});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController(text: '${DateTime.now().year}');
  final _copiesController = TextEditingController(text: '3');
  final _shelfController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = MockData.categories.first;
  bool _isLoading = false;

  bool get isEditing => widget.bookId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bookProv = Provider.of<BookProvider>(context, listen: false);
        final book = bookProv.getBookById(widget.bookId!);
        if (book != null) {
          setState(() {
            _titleController.text = book.title;
            _authorController.text = book.authorName;
            _isbnController.text = book.isbn;
            _publisherController.text = book.publisher;
            _yearController.text = '${book.publishedYear}';
            _copiesController.text = '${book.totalCopies}';
            _shelfController.text = book.shelfLocation;
            if (MockData.categories.contains(book.categoryName)) {
              _selectedCategory = book.categoryName;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _copiesController.dispose();
    _shelfController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final bookProv = Provider.of<BookProvider>(context, listen: false);
    final totalCopies = int.tryParse(_copiesController.text) ?? 1;
    final publishedYear = int.tryParse(_yearController.text) ?? DateTime.now().year;

    if (isEditing) {
      final existing = bookProv.getBookById(widget.bookId!);
      final updated = BookModel(
        id: widget.bookId!,
        title: _titleController.text.trim(),
        isbn: _isbnController.text.trim(),
        authorId: existing?.authorId ?? 'auth_custom',
        authorName: _authorController.text.trim(),
        categoryId: 'cat_custom',
        categoryName: _selectedCategory,
        publisher: _publisherController.text.trim(),
        publishedYear: publishedYear,
        totalCopies: totalCopies,
        availableCopies: existing != null
            ? (totalCopies - (existing.totalCopies - existing.availableCopies)).clamp(0, totalCopies)
            : totalCopies,
        shelfLocation: _shelfController.text.trim(),
        status: existing?.status ?? BookStatus.available,
      );
      bookProv.updateBook(updated);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Book updated successfully!');
        Navigator.pop(context);
      }
    } else {
      final newBook = BookModel(
        id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        isbn: _isbnController.text.trim(),
        authorId: 'auth_custom',
        authorName: _authorController.text.trim(),
        categoryId: 'cat_custom',
        categoryName: _selectedCategory,
        publisher: _publisherController.text.trim(),
        publishedYear: publishedYear,
        totalCopies: totalCopies,
        availableCopies: totalCopies,
        shelfLocation: _shelfController.text.trim(),
        status: BookStatus.available,
        createdAt: DateTime.now(),
      );
      bookProv.addBook(newBook);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'New book added to catalog!');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Update Book Information' : 'Catalog New Book Entry',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fill in catalog metadata for circulation and inventory tracking.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const Divider(height: 32),
                      AppTextField(
                        label: 'Book Title',
                        hint: 'e.g. Design Patterns: Elements of Reusable Object-Oriented Software',
                        controller: _titleController,
                        prefixIcon: const Icon(Icons.title),
                        validator: (v) => Validators.requiredField(v, 'Book title'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Author Name',
                              hint: 'e.g. Erich Gamma, Richard Helm',
                              controller: _authorController,
                              prefixIcon: const Icon(Icons.person_outline),
                              validator: (v) => Validators.requiredField(v, 'Author name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'ISBN Number',
                              hint: '978-0201633610',
                              controller: _isbnController,
                              prefixIcon: const Icon(Icons.numbers),
                              validator: Validators.isbn,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Category / Genre',
                              value: _selectedCategory,
                              items: MockData.categories.map((cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat));
                              }).toList(),
                              onChanged: (cat) {
                                if (cat != null) setState(() => _selectedCategory = cat);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Publisher',
                              hint: 'e.g. Addison-Wesley',
                              controller: _publisherController,
                              prefixIcon: const Icon(Icons.business_outlined),
                              validator: (v) => Validators.requiredField(v, 'Publisher'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Publication Year',
                              hint: '2022',
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              validator: (v) => Validators.requiredField(v, 'Publication year'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Number of Copies',
                              hint: '3',
                              controller: _copiesController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.content_copy_outlined),
                              validator: (v) => Validators.requiredField(v, 'Copies count'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Shelf Location',
                              hint: 'CS-B2-05',
                              controller: _shelfController,
                              prefixIcon: const Icon(Icons.room_outlined),
                              validator: (v) => Validators.requiredField(v, 'Shelf location'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Description / Abstract (Optional)',
                        hint: 'Brief synopsis or topics covered by this book...',
                        controller: _descriptionController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            text: isEditing ? 'Save Changes' : 'Catalog Book',
                            isLoading: _isLoading,
                            onPressed: _saveBook,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
