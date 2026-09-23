import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../core/mock/mock_data.dart';
import '../repositories/book_repository.dart';

/// Book catalog management state provider backed by BookRepository & Cloud Firestore
class BookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;

  List<BookModel> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedAvailability = 'All'; // 'All', 'Available', 'Out of Stock'
  String _sortBy = 'Title'; // 'Title', 'Year', 'Availability'

  BookProvider({BookRepository? bookRepository})
      : _bookRepository = bookRepository ?? BookRepository() {
    _loadBooks();
  }

  List<BookModel> get allBooks => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedAvailability => _selectedAvailability;
  String get sortBy => _sortBy;

  Future<void> _loadBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudBooks = await _bookRepository.getBooks();
      if (cloudBooks.isNotEmpty) {
        _books = cloudBooks;
      } else {
        _books = MockData.getInitialBooks();
      }
    } catch (_) {
      _books = MockData.getInitialBooks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadBooks();
  }

  List<BookModel> get filteredBooks {
    var result = _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.authorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.isbn.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          book.categoryName.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesAvailability = _selectedAvailability == 'All' ||
          (_selectedAvailability == 'Available' && book.availableCopies > 0) ||
          (_selectedAvailability == 'Out of Stock' && book.availableCopies == 0);

      return matchesSearch && matchesCategory && matchesAvailability;
    }).toList();

    switch (_sortBy) {
      case 'Title':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Year':
        result.sort((a, b) => b.publishedYear.compareTo(a.publishedYear));
        break;
      case 'Availability':
        result.sort((a, b) => b.availableCopies.compareTo(a.availableCopies));
        break;
    }

    return result;
  }

  List<String> get categories {
    final set = _books.map((b) => b.categoryName).toSet();
    return ['All', ...set];
  }

  bool get onlyAvailable => _selectedAvailability == 'Available';

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setAvailability(String availability) {
    _selectedAvailability = availability;
    notifyListeners();
  }

  void toggleAvailableOnly() {
    _selectedAvailability = _selectedAvailability == 'Available' ? 'All' : 'Available';
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  BookModel? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addBook(BookModel book) async {
    _books.insert(0, book);
    notifyListeners();

    try {
      await _bookRepository.addBook(book);
    } catch (_) {}
  }

  Future<void> updateBook(BookModel book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
      notifyListeners();

      try {
        await _bookRepository.updateBook(book);
      } catch (_) {}
    }
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();

    try {
      await _bookRepository.deleteBook(id);
    } catch (_) {}
  }

  void decrementAvailableCopies(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final current = _books[index];
      if (current.availableCopies > 0) {
        _books[index] = current.copyWith(
          availableCopies: current.availableCopies - 1,
        );
        notifyListeners();
      }
    }
  }

  void incrementAvailableCopies(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final current = _books[index];
      if (current.availableCopies < current.totalCopies) {
        _books[index] = current.copyWith(
          availableCopies: current.availableCopies + 1,
        );
        notifyListeners();
      }
    }
  }

  void adjustBookCopies(String bookId, int delta) {
    if (delta > 0) {
      for (int i = 0; i < delta; i++) {
        incrementAvailableCopies(bookId);
      }
    } else if (delta < 0) {
      for (int i = 0; i < -delta; i++) {
        decrementAvailableCopies(bookId);
      }
    }
  }
}
