import 'package:cloud_firestore/cloud_firestore.dart';

class AmenityModel {
  final String id;
  final String name;
  final String description;
  final List<String> photoURLs;
  final int capacity;
  final int hourlyRate;
  final int? deposit;
  final String rules;
  final List<String> availableDays;
  final String hours;
  final int maxBookingsPerMonth;

  const AmenityModel({
    required this.id,
    required this.name,
    required this.description,
    this.photoURLs = const [],
    required this.capacity,
    required this.hourlyRate,
    this.deposit,
    this.rules = '',
    this.availableDays = const [],
    this.hours = '8:00 - 22:00',
    this.maxBookingsPerMonth = 2,
  });

  factory AmenityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AmenityModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      photoURLs: List<String>.from(data['photoURLs'] ?? []),
      capacity: data['capacity'] ?? 0,
      hourlyRate: data['hourlyRate'] ?? 0,
      deposit: data['deposit'],
      rules: data['rules'] ?? '',
      availableDays: List<String>.from(data['availableDays'] ?? []),
      hours: data['hours'] ?? '8:00 - 22:00',
      maxBookingsPerMonth: data['maxBookingsPerMonth'] ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'photoURLs': photoURLs,
    'capacity': capacity,
    'hourlyRate': hourlyRate,
    'deposit': deposit,
    'rules': rules,
    'availableDays': availableDays,
    'hours': hours,
    'maxBookingsPerMonth': maxBookingsPerMonth,
  };

  int get totalCost => hourlyRate + (deposit ?? 0);
}

enum BookingStatus {
  confirmed('Confirmada'),
  cancelled('Cancelada'),
  completed('Completada');

  final String label;
  const BookingStatus(this.label);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.confirmed,
    );
  }
}

class BookingModel {
  final String id;
  final String amenityId;
  final String amenityName;
  final String residentUid;
  final String residentName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalPaid;
  final int? depositPaid;
  final bool depositRefunded;
  final BookingStatus status;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.amenityId,
    required this.amenityName,
    required this.residentUid,
    required this.residentName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPaid,
    this.depositPaid,
    this.depositRefunded = false,
    this.status = BookingStatus.confirmed,
    required this.createdAt,
  });

  factory BookingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      amenityId: data['amenityId'] ?? '',
      amenityName: data['amenityName'] ?? '',
      residentUid: data['residentUid'] ?? '',
      residentName: data['residentName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      totalPaid: data['totalPaid'] ?? 0,
      depositPaid: data['depositPaid'],
      depositRefunded: data['depositRefunded'] ?? false,
      status: BookingStatus.fromString(data['status'] ?? 'confirmed'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'amenityId': amenityId,
    'amenityName': amenityName,
    'residentUid': residentUid,
    'residentName': residentName,
    'date': Timestamp.fromDate(date),
    'startTime': startTime,
    'endTime': endTime,
    'totalPaid': totalPaid,
    'depositPaid': depositPaid,
    'depositRefunded': depositRefunded,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
