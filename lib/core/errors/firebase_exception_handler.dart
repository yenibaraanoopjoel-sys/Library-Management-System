import 'package:firebase_core/firebase_core.dart';
import 'app_exception.dart';

/// Maps Firebase and Firestore error codes to user-friendly messages
class FirebaseExceptionHandler {
  static AppException handle(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        // Auth Errors
        case 'user-not-found':
          return const AuthException(
            message: 'No registered user found with this email address.',
            code: 'user-not-found',
          );
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthException(
            message: 'Incorrect password or invalid credentials. Please try again.',
            code: 'wrong-password',
          );
        case 'email-already-in-use':
          return const AuthException(
            message: 'This email address is already registered. Please sign in instead.',
            code: 'email-already-in-use',
          );
        case 'invalid-email':
          return const AuthException(
            message: 'The email address format is invalid.',
            code: 'invalid-email',
          );
        case 'weak-password':
          return const AuthException(
            message: 'The password is too weak. Please use at least 6 characters.',
            code: 'weak-password',
          );
        case 'user-disabled':
          return const AuthException(
            message: 'This user account has been disabled. Please contact the administrator.',
            code: 'user-disabled',
          );
        case 'too-many-requests':
          return const AuthException(
            message: 'Too many unsuccessful attempts. Please try again in a few minutes.',
            code: 'too-many-requests',
          );

        // Firestore Database Errors
        case 'permission-denied':
          return const DatabaseException(
            message: 'You do not have authorization to perform this action.',
            code: 'permission-denied',
          );
        case 'not-found':
          return const NotFoundException(
            message: 'The requested library record was not found in the database.',
          );
        case 'already-exists':
          return const DatabaseException(
            message: 'A record with this identifier already exists.',
            code: 'already-exists',
          );
        case 'cancelled':
          return const DatabaseException(
            message: 'The database operation was cancelled.',
            code: 'cancelled',
          );
        case 'deadline-exceeded':
          return const NetworkException(
            message: 'Request timed out. Please check your internet connection.',
          );
        case 'unavailable':
          return const NetworkException(
            message: 'The library database service is currently unavailable. Please retry shortly.',
          );
        case 'failed-precondition':
          return DatabaseException(
            message: error.message ?? 'Database query requires a composite index or precondition failed.',
            code: 'failed-precondition',
          );
        case 'aborted':
          return const DatabaseException(
            message: 'The transaction was aborted due to a conflict. Please retry.',
            code: 'aborted',
          );
        case 'resource-exhausted':
          return const DatabaseException(
            message: 'Database quota exceeded. Please contact system administration.',
            code: 'resource-exhausted',
          );
        case 'unauthenticated':
          return const AuthException(
            message: 'You must be logged in to access this library resource.',
            code: 'unauthenticated',
          );

        // Network Errors
        case 'network-request-failed':
          return const NetworkException(
            message: 'Network connection failure. Please check your internet connectivity.',
          );

        default:
          return AppException(
            message: error.message ?? 'A database error occurred (${error.code}).',
            code: error.code,
          );
      }
    }
    return AppException(message: error.toString());
  }
}
