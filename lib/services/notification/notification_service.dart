import '../../models/notification_model.dart';
import '../firebase/firestore_service.dart';

/// Notification service managing in-app alerts, due notices, and fine messages in Firestore
class NotificationService {
  final FirestoreService _firestoreService;

  NotificationService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _firestoreService.notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final query = await _firestoreService.notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String relatedId = '',
  }) async {
    final docRef = _firestoreService.notificationsCollection.doc();
    final notification = NotificationModel(
      id: docRef.id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      relatedId: relatedId,
      createdAt: DateTime.now(),
    );

    await docRef.set(notification.toMap());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.updateDocument(
      _firestoreService.notificationsCollection,
      notificationId,
      {'isRead': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _firestoreService.notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestoreService.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.notificationsCollection,
      notificationId,
    );
  }

  Future<void> sendOverdueReminder(String memberId, String bookTitle, {String? userId}) async {
    await createNotification(
      userId: userId ?? memberId,
      title: 'Book Overdue Alert',
      message: 'Your borrowed book "$bookTitle" is past due. Please return it to avoid additional fees.',
      type: 'overdue',
      relatedId: memberId,
    );
  }
}
