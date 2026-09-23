# Cloud Firestore Database Architecture & Transaction Model

Project: **library-management-syste-d58c1**

## 1. Architectural Pattern

The Library Management System utilizes a root-level collection architecture for Cloud Firestore. This provides:
1. **Independent Queries:** Shallow root collections avoid nested subcollection query overhead.
2. **Deterministic Role-Based Security:** Rules cleanly evaluate `/users/$(request.auth.uid).role`.
3. **Atomic Multi-Document Consistency:** Full support for `runTransaction` across multiple root collections.

---

## 2. Entity Relationships & Cross-Collection References

```
[users] (Auth UID)
   │
   ├── role: 'admin' ──► Full administrative permissions across all collections
   ├── role: 'librarian' ──► Circulation management, inventory & member operations
   └── role: 'member' ────► Linked to patron record
          │
          ▼
      [members] (memberId)
          │
          ├── 1:N ──► [borrowings] (borrowingId) ◄── 1:N ── [books] (bookId)
          │                │                                   │
          ├── 1:N ──► [fines]                                  ├── N:1 ──► [authors]
          │                                                    └── N:1 ──► [categories]
          ▼
   [notifications] ◄── Generated automatically on checkout, return & fine assessment
          ▲
   [activities] ◄── Real-time system telemetry stream
```

---

## 3. Atomic Transaction Workflows

### Workflow A: Book Checkout (`issueBook`)
Executed within a single Firestore transaction:
1. `GET /books/{bookId}` ➔ Verify `availableCopies > 0`.
2. `GET /members/{memberId}` ➔ Verify `status == 'active'`.
3. `UPDATE /books/{bookId}` ➔ Decrement `availableCopies` by 1; if 0, set `status = 'borrowed'`.
4. `UPDATE /members/{memberId}` ➔ Increment `currentBorrowed` by 1 and `totalBorrowed` by 1.
5. `CREATE /borrowings/{borrowingId}` ➔ Write loan record with `status: 'ACTIVE'`, `issueDate`, `dueDate`.
6. `CREATE /activities/{activityId}` ➔ Append `BOOK_ISSUED` audit entry.
7. `CREATE /notifications/{notificationId}` ➔ Alert patron with book title and scheduled due date.

### Workflow B: Book Return (`returnBook`)
Executed within a single Firestore transaction:
1. `GET /borrowings/{borrowingId}` ➔ Verify record exists and `status != 'RETURNED'`.
2. Calculate overdue penalty:
   ```dart
   overdueDays = returnDate.difference(dueDate).inDays;
   fineAmount = overdueDays > 0 ? overdueDays * dailyFineRate : 0.0;
   ```
3. `UPDATE /borrowings/{borrowingId}` ➔ Set `status: 'RETURNED'`, `returnDate`, `fineAmount`.
4. `UPDATE /books/{bookId}` ➔ Increment `availableCopies` by 1 (clamped to `totalCopies`), set `status = 'available'`.
5. `UPDATE /members/{memberId}` ➔ Decrement `currentBorrowed` by 1; add `fineAmount` to `outstandingFine`.
6. If `fineAmount > 0`:
   - `CREATE /fines/{fineId}` ➔ Write fine invoice with status `'PENDING'`.
   - `CREATE /activities/{activityId}` ➔ Append `FINE_CREATED` audit entry.
7. `CREATE /activities/{activityId}` ➔ Append `BOOK_RETURNED` audit entry.
8. `CREATE /notifications/{notificationId}` ➔ Dispatch return confirmation (and fee alert if fine incurred).

### Workflow C: Fine Settlement (`payFine`)
Executed within a single Firestore transaction:
1. `GET /fines/{fineId}` ➔ Verify fine is unpaid.
2. `UPDATE /fines/{fineId}` ➔ Set `status: 'PAID'`, `paidAt`.
3. `UPDATE /members/{memberId}` ➔ Deduct amount from `outstandingFine`.
4. `CREATE /activities/{activityId}` ➔ Append `FINE_PAID` audit entry.

---

## 4. Required Composite Indexes (`firestore.indexes.json`)

| Collection | Field 1 | Field 2 | Use Case |
|---|---|---|---|
| `borrowings` | `status` (ASC) | `dueDate` (ASC) | Active loans sorted by nearest deadline |
| `borrowings` | `memberId` (ASC) | `issueDate` (DESC) | Patron loan history chronological view |
| `borrowings` | `bookId` (ASC) | `issueDate` (DESC) | Book circulation frequency and history |
| `fines` | `memberId` (ASC) | `issuedAt` (DESC) | Patron fee ledger and invoices |
| `fines` | `status` (ASC) | `issuedAt` (DESC) | Unpaid vs paid fine management queue |
| `notifications` | `userId` (ASC) | `createdAt` (DESC) | User inbox latest notifications |
| `notifications` | `userId` (ASC) | `isRead` (ASC) | Unread notification badge count |
| `books` | `categoryName` (ASC) | `availableCopies` (DESC) | Category filtering with availability sort |
| `members` | `status` (ASC) | `joinedAt` (DESC) | Member status filter & registration sort |
