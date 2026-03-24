import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class JobProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<JobModel> _todayJobs = [];
  StreamSubscription? _todayJobsSub;
  String _currentDateKey = '';

  List<JobModel> get todayJobs => _todayJobs;
  String get currentDateKey => _currentDateKey;

  // ─── Dashboard stats ───
  int get totalRepairs =>
      _todayJobs.where((j) => j.category == 'Repair').length;
  int get totalServices =>
      _todayJobs.where((j) => j.category == 'Service').length;
  int get totalMaintenance =>
      _todayJobs.where((j) => j.category == 'Maintenance').length;
  int get totalInstallations =>
      _todayJobs.where((j) => j.category == 'Installation').length;
  int get totalUniqueCustomers =>
      _todayJobs.map((j) => j.mobileNumber).toSet().length;

  double get todayRevenue =>
      _todayJobs.fold(0.0, (sum, j) => sum + j.price);

  /// Get jobs filtered by category
  List<JobModel> getJobsByCategory(String category) =>
      _todayJobs.where((j) => j.category == category).toList();

  /// Listen to today's jobs in real-time
  void listenToTodayJobs(String uid) {
    _currentDateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayJobsSub?.cancel();
    _todayJobsSub =
        _firestoreService.getTodayJobsStream(uid, _currentDateKey).listen((jobs) {
      _todayJobs = jobs;
      notifyListeners();
    });

    // Set up a timer to reset at midnight
    _scheduleMidnightReset(uid);
  }

  void _scheduleMidnightReset(String uid) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);

    Future.delayed(duration, () {
      listenToTodayJobs(uid);
    });
  }

  /// Add a new job
  Future<void> addJob(String uid, JobModel job) async {
    await _firestoreService.addJob(uid, job);
  }

  /// Update a job
  Future<void> updateJob(String uid, String jobId, JobModel job) async {
    await _firestoreService.updateJob(uid, jobId, job.toMap());
  }

  /// Delete a job
  Future<void> deleteJob(String uid, String jobId) async {
    await _firestoreService.deleteJob(uid, jobId);
  }

  /// Stream all jobs for history
  Stream<List<JobModel>> getAllJobs(String uid) {
    return _firestoreService.getAllJobsStream(uid);
  }

  /// Stream jobs for a given month
  Stream<List<JobModel>> getMonthJobs(String uid, int year, int month) {
    final yearMonth =
        '${year.toString()}-${month.toString().padLeft(2, '0')}';
    return _firestoreService.getMonthJobsStream(uid, yearMonth);
  }

  void clear() {
    _todayJobsSub?.cancel();
    _todayJobs = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _todayJobsSub?.cancel();
    super.dispose();
  }
}
