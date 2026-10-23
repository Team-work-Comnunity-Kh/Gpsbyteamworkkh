class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String language;

  const UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.language,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
        ? json['displayName'] as String
        : '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
    avatarUrl: (json['avatarUrl'] ?? json['avatar']) as String?,
    role: json['role'] as String? ?? 'user',
    language: json['language'] as String? ?? 'km',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'role': role,
    'language': language,
  };
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  final UserModel user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresIn: json['expiresIn']?.toString() ?? '',
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}
