/// Librarian entity model
class LibrarianModel {
  final String id;
  final String userId;
  final String employeeId;
  final String name;
  final String email;
  final String department;
  final DateTime? hireDate;

  const LibrarianModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.department,
    this.hireDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'department': department,
      'hireDate': hireDate?.toIso8601String(),
    };
  }

  factory LibrarianModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LibrarianModel(
      id: documentId,
      userId: map['userId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      hireDate: map['hireDate'] != null ? DateTime.tryParse(map['hireDate']) : null,
    );
  }
}
