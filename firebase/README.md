# Firebase Architecture & Deployment Guide

Project ID: **library-management-syste-d58c1**  
Platform: **Flutter (Web, Windows, Android, iOS)**  
Data Layer: **Firebase Authentication, Cloud Firestore, Firebase Storage**

---

## 🚀 Deployment Instructions

### 1. Configure Firebase Project
Your Firebase project is linked to `library-management-syste-d58c1`.
To re-generate or verify platform options:
```bash
flutterfire configure --project=library-management-syste-d58c1
```

### 2. Deploy Firestore Security Rules & Composite Indexes
Deploy the production security rules and composite indexes defined in this repository:
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 🛡️ Security Model

- **Unauthenticated**: Zero access to protected library records.
- **Student / Member (`role: member`)**:
  - Read-only catalog access (`books`, `authors`, `categories`).
  - Read-only access to their own member record, borrowing loans, fines, and notifications.
  - Can edit only their personal profile (`fullName`, `phone`, `profileImage`). Cannot alter roles, loans, or fines.
- **Librarian (`role: librarian`)**:
  - Full circulation operations (Issue books, return books, manage catalog, manage patrons, assess/waive fines, review telemetry).
- **Administrator (`role: admin`)**:
  - Full system administration including user account roles, system-wide audits, and destructive actions.

---

## 🔄 Cloud Firestore Collections

1. `/users/{uid}`: Authenticated user profiles and assigned roles.
2. `/members/{memberId}`: Enrolled library patrons (borrowing limits, active loan counts, outstanding fines).
3. `/books/{bookId}`: Catalog titles with atomic copy availability tracking (`availableCopies <= totalCopies`).
4. `/authors/{authorId}`: Author profiles.
5. `/categories/{categoryId}`: Catalog genre classifications.
6. `/borrowings/{borrowingId}`: Circulation loans (`ACTIVE`, `RETURNED`, `OVERDUE`).
7. `/fines/{fineId}`: Fee assessment ledger (`PENDING`, `PAID`, `WAIVED`).
8. `/activities/{activityId}`: Real-time circulation activity stream.
9. `/notifications/{notificationId}`: Targeted user reminders and due date notices.

---

## ⚡ Atomic Transactions

All circulation operations that mutate multiple documents are performed via atomic Firestore transactions:
- **`issueBook`**: Verifies available copies and active member status, decrements book copies, increments member loans, writes borrowing loan, logs activity, and dispatches notification.
- **`returnBook`**: Restores book copy, decrements member loan count, assesses fine if overdue, writes fine document, logs return activity, and dispatches notification.
- **`payFine` & `waiveFine`**: Updates fine status to `PAID`/`WAIVED`, decrements member outstanding balance, and appends audit log.

---

## 🌱 Development Data Seeding

The application includes `SeedService` (`lib/services/firebase/seed_service.dart`).
On initial startup, if the `books` collection in Cloud Firestore is empty, it automatically populates the initial catalog, categories, and demo accounts in batches.
