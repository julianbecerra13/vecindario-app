import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

enum FinanceType {
  income('Ingreso', AppColors.success, Icons.arrow_downward),
  expense('Egreso', AppColors.error, Icons.arrow_upward);

  final String label;
  final Color color;
  final IconData icon;
  const FinanceType(this.label, this.color, this.icon);

  static FinanceType fromString(String value) {
    return value == 'expense' ? FinanceType.expense : FinanceType.income;
  }
}

class FinanceEntryModel {
  final String id;
  final FinanceType type;
  final String category;
  final String description;
  final int amount;
  final DateTime date;
  final String? receiptURL;
  final String? approvedByUid;
  final DateTime createdAt;

  const FinanceEntryModel({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.receiptURL,
    this.approvedByUid,
    required this.createdAt,
  });

  factory FinanceEntryModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return FinanceEntryModel(
      id: id,
      type: FinanceType.fromString(data['type'] ?? 'income'),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      amount: data['amount'] ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      receiptURL: data['receiptURL'],
      approvedByUid: data['approvedByUid'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'category': category,
    'description': description,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'receiptURL': receiptURL,
    'approvedByUid': approvedByUid,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class AccountStatementModel {
  final String id;
  final String unitNumber;
  final String residentUid;
  final List<StatementItem> items;
  final int balance;
  final DateTime lastUpdated;

  const AccountStatementModel({
    required this.id,
    required this.unitNumber,
    required this.residentUid,
    this.items = const [],
    this.balance = 0,
    required this.lastUpdated,
  });

  factory AccountStatementModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return AccountStatementModel(
      id: id,
      unitNumber: data['unitNumber'] ?? '',
      residentUid: data['residentUid'] ?? '',
      items:
          (data['items'] as List?)
              ?.map((e) => StatementItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      balance: data['balance'] ?? 0,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool get isUpToDate => balance <= 0;
}

class StatementItem {
  final String concept;
  final int amount;
  final DateTime date;
  final String status;

  const StatementItem({
    required this.concept,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory StatementItem.fromMap(Map<String, dynamic> map) {
    return StatementItem(
      concept: map['concept'] ?? '',
      amount: map['amount'] ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }
}

class AssemblyModel {
  final String id;
  final String title;
  final List<String> agenda;
  final DateTime date;
  final String? location;
  final String? virtualLink;
  final List<String> attendees;
  final List<VoteItem> votes;
  final String? actaPdfURL;
  final String status; // convened, active, closed

  const AssemblyModel({
    required this.id,
    required this.title,
    this.agenda = const [],
    required this.date,
    this.location,
    this.virtualLink,
    this.attendees = const [],
    this.votes = const [],
    this.actaPdfURL,
    this.status = 'convened',
  });

  factory AssemblyModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AssemblyModel(
      id: id,
      title: data['title'] ?? '',
      agenda: List<String>.from(data['agenda'] ?? []),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'],
      virtualLink: data['virtualLink'],
      attendees: List<String>.from(data['attendees'] ?? []),
      votes:
          (data['votes'] as List?)
              ?.map((e) => VoteItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      actaPdfURL: data['actaPdfURL'],
      status: data['status'] ?? 'convened',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'agenda': agenda,
    'date': Timestamp.fromDate(date),
    'location': location,
    'virtualLink': virtualLink,
    'attendees': attendees,
    'votes': votes.map((e) => e.toMap()).toList(),
    'actaPdfURL': actaPdfURL,
    'status': status,
  };

  bool get isLive => status == 'active';
  int get quorum => attendees.length;
}

class VoteItem {
  final String topic;
  final List<String> options;
  final Map<String, List<String>> results; // option -> list of uids

  const VoteItem({
    required this.topic,
    required this.options,
    this.results = const {},
  });

  factory VoteItem.fromMap(Map<String, dynamic> map) {
    final results = <String, List<String>>{};
    if (map['results'] != null) {
      (map['results'] as Map<String, dynamic>).forEach((key, value) {
        results[key] = List<String>.from(value);
      });
    }
    return VoteItem(
      topic: map['topic'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      results: results,
    );
  }

  Map<String, dynamic> toMap() => {
    'topic': topic,
    'options': options,
    'results': results,
  };

  int totalVotes() => results.values.fold(0, (sum, list) => sum + list.length);

  double percentageFor(String option) {
    final total = totalVotes();
    if (total == 0) return 0;
    return (results[option]?.length ?? 0) / total;
  }

  bool hasVoted(String uid) => results.values.any((list) => list.contains(uid));
}
