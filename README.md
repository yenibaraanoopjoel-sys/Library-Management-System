# 📚 Libra System — Intelligent Library Management Platform

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State%20Management-6C3483?style=for-the-badge)
![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A professional, scalable, multiplatform Library Management System built with Flutter, Provider, and Firebase.**

[🌐 Live Web App](https://library-management-syste-d58c1.web.app) &nbsp;|&nbsp;
[🔥 Firebase Console](https://console.firebase.google.com/project/library-management-syste-d58c1) &nbsp;|&nbsp;
[📦 GitHub Repository](https://github.com/yenibaraanoopjoel-sys/Library-Management-System)

</div>

---

## 🔗 Live Links

| Resource | URL |
|---|---|
| 🌐 **Live Web App** | https://library-management-syste-d58c1.web.app |
| 🔥 **Alternate Domain** | https://library-management-syste-d58c1.firebaseapp.com |
| 📦 **GitHub Repository** | https://github.com/yenibaraanoopjoel-sys/Library-Management-System |
| 🛠️ **Firebase Console** | https://console.firebase.google.com/project/library-management-syste-d58c1 |
| 🗄️ **Firestore Database** | https://console.firebase.google.com/project/library-management-syste-d58c1/firestore |
| 🔐 **Firebase Auth** | https://console.firebase.google.com/project/library-management-syste-d58c1/authentication |
| 🗃️ **Firebase Storage** | https://console.firebase.google.com/project/library-management-syste-d58c1/storage |

---

## 📖 About the Project

**Libra System** is a modern, full-featured Library Management Platform designed for educational institutions, public libraries, and private collections. It provides role-based access for Admins, Librarians, and Members — enabling seamless management of books, borrowing, returns, fines, and member accounts through an intuitive web and desktop interface.

### ✨ Why Libra System?

- **Multiplatform** — Runs on Web (primary), Windows, Android, and iOS from a single Flutter codebase.
- **Real-time** — Powered by Cloud Firestore for instant, live updates across all users.
- **Role-Based** — Three-tier access control: Admin → Librarian → Member/Student.
- **Production-Ready Architecture** — Feature-first, Clean Architecture with strict separation of concerns.
- **Fully Tested** — Unit, widget, and end-to-end integration test suites included.

---

## 🚀 Key Features

### 📚 Book Management
- Add, edit, delete, and archive books with cover images (Firebase Storage)
- Full-text search across title, author, ISBN, genre
- Track real-time availability (total copies vs. available copies)
- Categorization by genre, language, publisher, and publication year

### 👤 Member Management
- Register and manage library members (students, faculty, public)
- Role assignment and permission control
- Member borrowing history and activity logs
- Account suspension and reinstatement workflows

### 🔄 Borrowing & Circulation
- Issue books to members with due-date tracking
- Renewal requests and approvals
- Real-time availability updates on issuance/return

### ↩️ Returns & Fines
- Process book returns and update inventory automatically
- Auto-calculate overdue fines based on configurable daily rates
- Fine payment tracking and waiver workflows

### 🔐 Authentication & Authorization
- Firebase Authentication (email/password)
- Role-based route guards (Admin, Librarian, Member)
- Secure session management and persistent login

### 🔔 Notifications
- In-app notification center for due-date reminders, overdue alerts, and approvals
- Real-time notification delivery via Cloud Firestore

### 📊 Dashboard & Analytics
- At-a-glance KPIs: total books, active borrows, overdue items, total members
- Visual charts for borrowing trends
- Role-specific dashboard views

### ⚙️ Settings & Profile
- User profile management with avatar upload
- App-wide theme and display preferences
- System configuration for fine rates, borrow limits, and loan periods

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Provider (ChangeNotifier) |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **File Storage** | Firebase Storage |
| **Hosting** | Firebase Hosting |
| **Fonts** | Google Fonts |
| **Testing** | flutter_test, integration_test |

---

## 📁 Architecture Overview

```
lib/
├── main.dart                  # Application entry point
├── firebase_options.dart      # Platform-specific Firebase credentials
├── app/                       # Core App setup (Theme, Config, Router, Constants)
├── core/                      # Shared constants, enums, errors, extensions, utils, widgets
├── models/                    # Data models (Firestore serialization/deserialization)
├── services/                  # Low-level service layer (Firebase, Auth, Notifications, Search)
├── repositories/              # Repository layer mediating services & business logic
├── providers/                 # State management layer (ChangeNotifier / Provider)
├── routing/                   # Declarative routing, route guards, and generator
└── features/                  # Feature-driven modular architecture
    ├── splash/                 # Splash / loading screen
    ├── authentication/         # Login, Register, Password Reset
    ├── dashboard/              # Analytics & KPI overview
    ├── books/                  # Book catalog & management
    ├── members/                # Member management
    ├── borrowing/              # Issue & track book loans
    ├── returns/                # Process book returns
    ├── fines/                  # Fine calculation & payment
    ├── profile/                # User profile & settings
    ├── search/                 # Global full-text search
    ├── settings/               # App & system configuration
    └── notifications/          # In-app notification center
```

Every feature module follows strict separation of concerns:
- `screens/` — UI screens and page-level views
- `widgets/` — Feature-specific reusable UI components
- `controllers/` — Presentation logic and screen state controllers

---

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>= 3.0.0`
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yenibaraanoopjoel-sys/Library-Management-System.git
   cd Library-Management-System
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** *(skip if using the shared dev project)*:
   ```bash
   flutterfire configure
   ```

4. **Run the application:**
   ```bash
   # Flutter Web (Primary target)
   flutter run -d chrome

   # Windows Desktop
   flutter run -d windows

   # Android
   flutter run -d android
   ```

---

## 🧪 Testing

```bash
# Run all unit & widget tests
flutter test

# Run integration tests (requires a running device/emulator)
flutter test integration_test/

# Run a specific test file
flutter test test/books_test.dart
```

---

## 🚀 Deployment

### Firebase Hosting (Web)

```bash
# Build the web release
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

The app is deployed at:
- **Primary:** https://library-management-syste-d58c1.web.app
- **Alternate:** https://library-management-syste-d58c1.firebaseapp.com

### Firestore Security Rules

```bash
# Deploy Firestore rules & indexes
firebase deploy --only firestore
```

---

## 🗂️ Firebase Project Details

| Setting | Value |
|---|---|
| **Project ID** | `library-management-syste-d58c1` |
| **Auth Domain** | `library-management-syste-d58c1.firebaseapp.com` |
| **Storage Bucket** | `library-management-syste-d58c1.appspot.com` |
| **Hosting URL** | `https://library-management-syste-d58c1.web.app` |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
Made with ❤️ using Flutter & Firebase
</div>