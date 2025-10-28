class Appointment {
  final String id;
  final String userId;
  final String serviceName;
  final DateTime dateTime;
  final String customerName;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.serviceName,
    required this.dateTime,
    required this.customerName,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceName': serviceName,
      'dateTime': dateTime.toIso8601String(),
      'customerName': customerName,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      serviceName: json['serviceName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      customerName: json['customerName'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Create a copy with updated fields
  Appointment copyWith({
    String? id,
    String? userId,
    String? serviceName,
    DateTime? dateTime,
    String? customerName,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final dayOfWeek = days[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;

    return '$dayOfWeek, $month $day, $year';
  }

  String get formattedTime {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'Appointment(id: $id, serviceName: $serviceName, dateTime: $dateTime, customerName: $customerName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}