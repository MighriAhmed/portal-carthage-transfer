class User {
  final String role;
  final String? supplierName;
  final String? username;
  final String? email;
  final String? phoneNumber;

  User({
    required this.role,
    this.supplierName,
    this.username,
    this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      role: json['role'] ?? '',
      supplierName: json['supplier_name'],
      username: json['username'] ?? json['sub'], // Use 'sub' as fallback for username
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'supplier_name': supplierName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isSupplier => role == 'supplier';

  @override
  String toString() {
    return 'User(role: $role, supplierName: $supplierName, username: $username)';
  }
} 