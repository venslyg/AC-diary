
class UserModel {
  final String uid;
  final String name;
  final String email;
  final double dailyMarginTarget;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.dailyMarginTarget = 30000.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      dailyMarginTarget: (map['dailyMarginTarget'] ?? 30000).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dailyMarginTarget': dailyMarginTarget,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    double? dailyMarginTarget,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      dailyMarginTarget: dailyMarginTarget ?? this.dailyMarginTarget,
    );
  }
}
