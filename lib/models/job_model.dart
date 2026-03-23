import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String? id;
  final String customerName;
  final String mobileNumber;
  final String category; // Repair, Service, Maintenance, Installation
  final String serviceType; // Full, Normal, N/A
  final double price;
  final bool isPaid;
  final DateTime timestamp;
  final String dateKey; // YYYY-MM-DD

  JobModel({
    this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.category,
    required this.serviceType,
    required this.price,
    required this.isPaid,
    required this.timestamp,
    required this.dateKey,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String docId) {
    return JobModel(
      id: docId,
      customerName: map['customerName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      category: map['category'] ?? 'Repair',
      serviceType: map['serviceType'] ?? 'N/A',
      price: (map['price'] ?? 0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateKey: map['dateKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'category': category,
      'serviceType': serviceType,
      'price': price,
      'isPaid': isPaid,
      'timestamp': Timestamp.fromDate(timestamp),
      'dateKey': dateKey,
    };
  }
}
