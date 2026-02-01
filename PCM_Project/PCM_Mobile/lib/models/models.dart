// Models for API responses

class User {
  final String id;
  final String username;
  final String email;
  final Member? member;
  final List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.member,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}

class Member {
  final int id;
  final String fullName;
  final String? email;
  final DateTime joinDate;
  final double rankLevel;
  final bool isActive;
  final double walletBalance;
  final String tier;
  final double totalSpent;
  final String? avatarUrl;

  Member({
    required this.id,
    required this.fullName,
    this.email,
    required this.joinDate,
    required this.rankLevel,
    required this.isActive,
    required this.walletBalance,
    required this.tier,
    required this.totalSpent,
    this.avatarUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'],
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      rankLevel: (json['rankLevel'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      tier: json['tier'] ?? 'Standard',
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      avatarUrl: json['avatarUrl'],
    );
  }
}

class Court {
  final int id;
  final String name;
  final String? location;
  final bool isActive;
  final String? description;
  final double pricePerHour;

  Court({
    required this.id,
    required this.name,
    this.location,
    required this.isActive,
    this.description,
    required this.pricePerHour,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'],
      isActive: json['isActive'] ?? true,
      description: json['description'],
      pricePerHour: (json['pricePerHour'] ?? json['hourlyRate'] ?? 0).toDouble(),
    );
  }
}

class Booking {
  final int id;
  final int courtId;
  final int memberId;
  final String? courtName;
  final Court? court;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final bool isRecurring;
  final String? recurrenceRule;
  final String status;
  final DateTime createdDate;

  Booking({
    required this.id,
    required this.courtId,
    required this.memberId,
    this.courtName,
    this.court,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.isRecurring,
    this.recurrenceRule,
    required this.status,
    required this.createdDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      courtId: json['courtId'] ?? 0,
      memberId: json['memberId'] ?? 0,
      courtName: json['courtName'],
      court: json['court'] != null ? Court.fromJson(json['court']) : null,
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      isRecurring: json['isRecurring'] ?? false,
      recurrenceRule: json['recurrenceRule'],
      status: json['status'] ?? 'PendingPayment',
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Tournament {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String format;
  final double entryFee;
  final double prizePool;
  final String status;
  final int participantCount;

  Tournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.format,
    required this.entryFee,
    required this.prizePool,
    required this.status,
    required this.participantCount,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      format: json['format'] ?? 'RoundRobin',
      entryFee: (json['entryFee'] ?? 0).toDouble(),
      prizePool: (json['prizePool'] ?? 0).toDouble(),
      status: json['status'] ?? 'Open',
      participantCount: json['participantCount'] ?? 0,
    );
  }
}

class TournamentParticipantModel {
  final int id;
  final int memberId;
  final String? teamName;
  final DateTime registeredDate;
  final String? memberFullName;

  TournamentParticipantModel({
    required this.id,
    required this.memberId,
    this.teamName,
    required this.registeredDate,
    this.memberFullName,
  });

  factory TournamentParticipantModel.fromJson(Map<String, dynamic> json) {
    return TournamentParticipantModel(
      id: json['id'] ?? 0,
      memberId: json['memberId'] ?? 0,
      teamName: json['teamName'],
      registeredDate: DateTime.parse(json['registeredDate'] ?? DateTime.now().toIso8601String()),
      memberFullName: json['memberFullName'],
    );
  }
}

class WalletTransaction {
  final int id;
  final int memberId;
  final double amount;
  final String type; // Deposit, Withdraw, Payment, etc.
  final String status; // Pending, Completed, Rejected
  final String? relatedId;
  final String? description;
  final DateTime createdDate;
  final String? proofImageUrl;

  WalletTransaction({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.type,
    required this.status,
    this.relatedId,
    this.description,
    required this.createdDate,
    this.proofImageUrl,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      memberId: json['memberId'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'Payment',
      status: json['status'] ?? 'Pending',
      relatedId: json['relatedId'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toIso8601String()),
      proofImageUrl: json['proofImageUrl'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
    );
  }
}
