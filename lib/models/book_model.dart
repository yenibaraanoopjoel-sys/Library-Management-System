import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/book_status.dart';

/// Book entity model mapping to Firestore 'books' collection
class BookModel {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final String categoryId;
  final String categoryName;
  final String isbn;
  final String publisher;
  final int publicationYear;
  final String description;
  final String? coverImage;
  final int totalCopies;
  final int availableCopies;
  final String shelfLocation;
  final BookStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookModel({
    required this.id,
    required this.title,
    this.authorId = '',
    String? authorName,
    String? author,
    this.categoryId = '',
    String? categoryName,
    String? category,
    this.isbn = '',
    this.publisher = '',
    int? publicationYear,
    int? publishedYear,
    this.description = '',
    this.coverImage,
    required this.totalCopies,
    required this.availableCopies,
    this.shelfLocation = '',
    this.status = BookStatus.available,
    this.createdAt,
    this.updatedAt,
  })  : authorName = authorName ?? author ?? '',
        categoryName = categoryName ?? category ?? '',
        publicationYear = publicationYear ?? publishedYear ?? 2024;

  // Backward compatibility getters
  String get author => authorName;
  String get category => categoryName;
  int get publishedYear => publicationYear;
  String? get coverImageUrl => coverImage;
  bool get isAvailable => availableCopies > 0;

  Map<String, dynamic> toMap() {
    // Ensure bounds constraint on copies
    final clampedAvailable = availableCopies.clamp(0, totalCopies);

    return {
      'id': id,
      'title': title,
      'authorId': authorId,
      'authorName': authorName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isbn': isbn,
      'publisher': publisher,
      'publicationYear': publicationYear,
      'description': description,
      'coverImage': coverImage,
      'totalCopies': totalCopies,
      'availableCopies': clampedAvailable,
      'shelfLocation': shelfLocation,
      'status': clampedAvailable > 0 ? 'available' : 'borrowed',
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    final total = (map['totalCopies'] as num?)?.toInt() ?? 1;
    final rawAvailable = (map['availableCopies'] as num?)?.toInt() ?? total;
    final clampedAvailable = rawAvailable.clamp(0, total);

    return BookModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      title: map['title'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      isbn: map['isbn'] ?? '',
      publisher: map['publisher'] ?? '',
      publicationYear: (map['publicationYear'] ?? map['publishedYear'] as num?)?.toInt() ?? DateTime.now().year,
      description: map['description'] ?? '',
      coverImage: map['coverImage'] ?? map['coverImageUrl'],
      totalCopies: total,
      availableCopies: clampedAvailable,
      shelfLocation: map['shelfLocation'] ?? '',
      status: clampedAvailable > 0 ? BookStatus.available : BookStatus.borrowed,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    try {
      return (val as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }

  BookModel copyWith({
    String? title,
    String? authorId,
    String? authorName,
    String? categoryId,
    String? categoryName,
    String? isbn,
    String? publisher,
    int? publicationYear,
    String? description,
    String? coverImage,
    int? totalCopies,
    int? availableCopies,
    String? shelfLocation,
    BookStatus? status,
    DateTime? updatedAt,
  }) {
    final newTotal = totalCopies ?? this.totalCopies;
    final newAvailable = (availableCopies ?? this.availableCopies).clamp(0, newTotal);

    return BookModel(
      id: id,
      title: title ?? this.title,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      totalCopies: newTotal,
      availableCopies: newAvailable,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      status: newAvailable > 0 ? BookStatus.available : BookStatus.borrowed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
