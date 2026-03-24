import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER OPERATIONS ───

  /// Create user document in Firestore
  Future<void> createUserDoc(String uid, String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'dailyMarginTarget': 30000.0,
    });
  }

  /// Get user document as a stream
  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return UserModel.fromMap(snap.data()!, snap.id);
      }
      return null;
    });
  }

  /// Get user document once
  Future<UserModel?> getUserDoc(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (snap.exists && snap.data() != null) {
      return UserModel.fromMap(snap.data()!, snap.id);
    }
    return null;
  }

  /// Update daily margin target
  Future<void> updateDailyMarginTarget(String uid, double target) async {
    await _db.collection('users').doc(uid).update({
      'dailyMarginTarget': target,
    });
  }

  // ─── JOB OPERATIONS ───

  /// Add a new job
  Future<void> addJob(String uid, JobModel job) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .add(job.toMap());
  }

  /// Update a job
  Future<void> updateJob(
      String uid, String jobId, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .doc(jobId)
        .update(data);
  }

  /// Delete a job
  Future<void> deleteJob(String uid, String jobId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .doc(jobId)
        .delete();
  }

  /// Stream of today's jobs (filtered by dateKey)
  /// Sorting done client-side to avoid needing a composite index
  Stream<List<JobModel>> getTodayJobsStream(String uid, String dateKey) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .where('dateKey', isEqualTo: dateKey)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data(), doc.id))
          .toList();
      jobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return jobs;
    });
  }

  /// Stream of jobs for a given month (YYYY-MM prefix)
  Stream<List<JobModel>> getMonthJobsStream(String uid, String yearMonth) {
    final start = '$yearMonth-01';
    final end = '$yearMonth-32';
    return _db
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .where('dateKey', isGreaterThanOrEqualTo: start)
        .where('dateKey', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data(), doc.id))
          .toList();
      jobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return jobs;
    });
  }

  /// Stream of all jobs for history (limit 500 to save reads)
  Stream<List<JobModel>> getAllJobsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .limit(500)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data(), doc.id))
          .toList();
      jobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return jobs;
    });
  }
}
