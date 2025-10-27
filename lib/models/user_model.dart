class User {
  final String id;
  final String email;
  final String name;
  final String userType; // 'user' or 'barber'
  final DateTime createdAt;
  final String? phoneNumber;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.createdAt,
    this.phoneNumber,
    this.profileImageUrl,
  });

  // Factory constructor to create a new user
  factory User.create({
    required String email,
    required String name,
    required String userType,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      userType: userType,
      createdAt: DateTime.now(),
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
  }

  // Convert User object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create User object from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      userType: json['userType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  // Helper to create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? userType,
    DateTime? createdAt,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Helper to check if user is a barber
  bool get isBarber => userType == 'barber';

  // Helper to check if user is a regular user
  bool get isUser => userType == 'user';

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
