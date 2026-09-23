# Firestore Collections & Schema Reference

Project: **library-management-syste-d58c1**

This document specifies the exact Cloud Firestore schema, field types, and document ID structures implemented for the Library Management System.

---

## 📚 Collections Inventory

### 1. `users`
Represents user profiles and permissions. Document ID is the Firebase Authentication `UID`.
- **Path:** `/users/{uid}`
- **Fields:**
  - `uid`: string (Primary UID)
  - `fullName`: string
  - `email`: string
  - `phone`: string
  - `role`: string (`admin` | `librarian` | `member`)
  - `profileImage`: string? (Storage download URL)
  - `memberId`: string? (Linked membership card reference)
  - `isActive`: boolean
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 2. `members`
Represents enrolled library patrons (Students, Faculty, Public Members).
- **Path:** `/members/{memberId}`
- **Fields:**
  - `id`: string
  - `userId`: string? (Linked Firebase user account UID)
  - `memberId`: string (Library Card ID, e.g. `MEM-001`)
  - `fullName`: string
  - `email`: string
  - `phone`: string
  - `address`: string
  - `profileImage`: string?
  - `joinedAt`: timestamp
  - `status`: string (`active` | `suspended` | `expired`)
  - `totalBorrowed`: int (Lifetime borrowing count)
  - `currentBorrowed`: int (Active loans count)
  - `outstandingFine`: double (Unpaid balance in USD)
  - `maxBooksAllowed`: int (Default 3-5)
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 3. `books`
Represents book titles in the library catalog.
- **Path:** `/books/{bookId}`
- **Fields:**
  - `id`: string
  - `title`: string
  - `authorId`: string
  - `authorName`: string
  - `categoryId`: string
  - `categoryName`: string
  - `isbn`: string (ISBN-10 or ISBN-13)
  - `publisher`: string
  - `publicationYear`: int
  - `description`: string
  - `coverImage`: string?
  - `totalCopies`: int
  - `availableCopies`: int (Clamped: `0 <= availableCopies <= totalCopies`)
  - `status`: string (`available` | `borrowed`)
  - `shelfLocation`: string
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 4. `authors`
Catalog authors registry.
- **Path:** `/authors/{authorId}`
- **Fields:**
  - `id`: string
  - `name`: string
  - `description`: string
  - `bookCount`: int
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 5. `categories`
Catalog subject classification genres.
- **Path:** `/categories/{categoryId}`
- **Fields:**
  - `id`: string
  - `name`: string
  - `description`: string
  - `bookCount`: int
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 6. `borrowings`
Tracks circulation loan transactions.
- **Path:** `/borrowings/{borrowingId}`
- **Fields:**
  - `id`: string
  - `bookId`: string
  - `bookTitle`: string
  - `memberId`: string
  - `memberName`: string
  - `issuedBy`: string (Librarian/Admin UID or name)
  - `issueDate`: timestamp
  - `dueDate`: timestamp
  - `returnDate`: timestamp?
  - `status`: string (`ACTIVE` | `RETURNED` | `OVERDUE`)
  - `fineAmount`: double
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 7. `fines`
Overdue penalty and fee tracking.
- **Path:** `/fines/{fineId}`
- **Fields:**
  - `id`: string
  - `borrowingId`: string
  - `memberId`: string
  - `memberName`: string
  - `bookId`: string
  - `amount`: double
  - `overdueDays`: int
  - `status`: string (`PENDING` | `PAID` | `WAIVED`)
  - `issuedAt`: timestamp
  - `paidAt`: timestamp?
  - `waivedAt`: timestamp?
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

### 8. `activities`
Real-time circulation audit stream.
- **Path:** `/activities/{activityId}`
- **Fields:**
  - `id`: string
  - `type`: string (`BOOK_ADDED`, `BOOK_UPDATED`, `BOOK_DELETED`, `MEMBER_ADDED`, `MEMBER_UPDATED`, `BOOK_ISSUED`, `BOOK_RETURNED`, `FINE_CREATED`, `FINE_PAID`, `FINE_WAIVED`)
  - `message`: string
  - `userId`: string
  - `userName`: string
  - `relatedId`: string
  - `createdAt`: timestamp

### 9. `notifications`
User alert and reminder queue.
- **Path:** `/notifications/{notificationId}`
- **Fields:**
  - `id`: string
  - `userId`: string (Target user UID or memberId)
  - `title`: string
  - `message`: string
  - `type`: string (`due_soon` | `overdue` | `fine` | `return` | `system`)
  - `isRead`: boolean
  - `relatedId`: string
  - `createdAt`: timestamp
