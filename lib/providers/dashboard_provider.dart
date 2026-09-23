import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../models/activity_model.dart';
import '../core/mock/mock_data.dart';
import '../repositories/dashboard_repository.dart';

/// Dashboard state provider supplying live Firestore metrics and real-time circulation telemetry
class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;

  DashboardModel _metrics = const DashboardModel();
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider({DashboardRepository? dashboardRepository})
      : _dashboardRepository = dashboardRepository ?? DashboardRepository() {
    _activities = MockData.getInitialActivities();
    loadDashboardMetrics();
  }

  DashboardModel get metrics => _metrics;
  List<ActivityModel> get recentActivities => _activities;
  List<ActivityModel> get recentActivity => _activities; // Backward compatibility
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardMetrics({String? studentMemberId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (studentMemberId != null) {
        _metrics = await _dashboardRepository.getStudentDashboardMetrics(studentMemberId);
      } else {
        _metrics = await _dashboardRepository.getAdminDashboardMetrics();
      }

      final cloudActivities = await _dashboardRepository.getRecentActivities(limit: 10);
      if (cloudActivities.isNotEmpty) {
        _activities = cloudActivities;
      }
    } catch (_) {
      // Retain in-memory values if offline
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addActivity({
    required String action,
    required String entityType,
    required String entityId,
    String userName = 'Alexander Morgan',
    String userId = 'usr_admin',
  }) {
    _activities.insert(
      0,
      ActivityModel(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        type: action,
        message: '$action $entityType #$entityId by $userName',
        relatedId: entityId,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
