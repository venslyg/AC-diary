import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _userModel;
  StreamSubscription? _userSub;

  UserModel? get userModel => _userModel;
  double get dailyMarginTarget => _userModel?.dailyMarginTarget ?? 30000.0;

  void listenToUser(String uid) {
    _userSub?.cancel();
    _userSub = _firestoreService.getUserStream(uid).listen((user) {
      _userModel = user;
      notifyListeners();
    });
  }

  Future<void> updateDailyMarginTarget(String uid, double target) async {
    await _firestoreService.updateDailyMarginTarget(uid, target);
  }

  void clear() {
    _userSub?.cancel();
    _userModel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
